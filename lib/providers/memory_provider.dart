import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../database/memory_database.dart';
import '../models/memory.dart';
import '../models/attachment.dart';
import '../services/cloud_sync_service.dart';
import '../services/memory_service.dart';

class MemoryProvider extends ChangeNotifier {
  final MemoryService _memoryService = MemoryService();

  List<Memory> memories = [];
  bool isLoading = false;
  bool isSyncing = false;
  String? errorMessage;

  MemoryProvider() {
    loadMemories();
  }

  Future<void> loadMemories() async {
    isLoading = true;
    notifyListeners();

    try {
      memories = await _memoryService.getAllMemories();
      errorMessage = null;
    } catch (e) {
      errorMessage = '加载记忆失败，请重启应用';
    }

    isLoading = false;
    notifyListeners();

    // 启动后自动从云端拉取
    _autoPullFromCloud();
  }

  /// 后台静默从云端拉取
  void _autoPullFromCloud() {
    if (!cloudAvailable) return;
    isSyncing = true;
    notifyListeners();
    unawaited(
      CloudSyncService().pullMemories(memories).then((count) {
        if (count > 0) {
          loadMemories(); // 重新加载以包含新数据
        }
        isSyncing = false;
        notifyListeners();
      }).catchError((_) {
        isSyncing = false;
        notifyListeners();
      }),
    );
  }

  /// 后台静默推送单条记忆到云端
  void _autoPushToCloud(Memory memory) {
    if (!cloudAvailable) return;
    isSyncing = true;
    notifyListeners();
    unawaited(
      CloudSyncService().pushMemory(memory).then((ok) {
        // 静默成功
        isSyncing = false;
        notifyListeners();
      }).catchError((_) {
        isSyncing = false;
        notifyListeners();
      }),
    );
  }

  /// 后台静默从云端删除
  void _autoDeleteFromCloud(Memory memory) {
    if (!cloudAvailable) return;
    isSyncing = true;
    notifyListeners();
    unawaited(
      CloudSyncService().deleteMemory(memory.content, memory.date).then((_) {
        isSyncing = false;
        notifyListeners();
      }).catchError((_) {
        isSyncing = false;
        notifyListeners();
      }),
    );
  }

  Future<int> addMemory(Memory memory,
      {List<File>? imageFiles, List<File>? docFiles}) async {
    try {
      final id = await _memoryService.addMemory(memory);
      memory.id = id;

      // 保存附件
      if (imageFiles != null) {
        for (final file in imageFiles) {
          await _saveAttachment(memory.id!, file, 'image');
        }
      }
      if (docFiles != null) {
        for (final file in docFiles) {
          await _saveAttachment(memory.id!, file, 'document');
        }
      }

      memories.add(memory);
      memories.sort((a, b) => b.date.compareTo(a.date));
      errorMessage = null;
      notifyListeners();

      // 自动同步到云端
      _autoPushToCloud(memory);

      return id;
    } catch (e) {
      errorMessage = '保存记忆失败，请重试';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMemory(Memory memory) async {
    try {
      if (memory.id != null) {
        // 删除附件文件
        final attachments =
            await MemoryDatabase.getAttachments(memory.id!);
        for (final a in attachments) {
          final f = File(a.filePath);
          if (await f.exists()) await f.delete();
        }
        await _memoryService.deleteMemory(memory.id!);
      }

      memories.remove(memory);
      errorMessage = null;
      notifyListeners();

      // 自动从云端删除
      _autoDeleteFromCloud(memory);
    } catch (e) {
      errorMessage = '删除记忆失败，请重试';
      notifyListeners();
    }
  }

  Future<void> updateMemory(
    Memory memory,
    String newContent,
    DateTime newDate,
    String newTags,
  ) async {
    try {
      memory.content = newContent;
      memory.date = newDate;
      memory.tags = newTags;

      await _memoryService.updateMemory(memory);

      memories.sort((a, b) => b.date.compareTo(a.date));
      errorMessage = null;
      notifyListeners();

      // 自动同步到云端
      _autoPushToCloud(memory);
    } catch (e) {
      errorMessage = '更新记忆失败，请重试';
      notifyListeners();
    }
  }

  Future<List<Attachment>> getAttachments(int memoryId) async {
    return await MemoryDatabase.getAttachments(memoryId);
  }

  Future<void> _saveAttachment(
      int memoryId, File sourceFile, String type) async {
    final dir = await getApplicationDocumentsDirectory();
    final subDir = Directory(p.join(dir.path, 'attachments', memoryId.toString()));
    if (!await subDir.exists()) {
      await subDir.create(recursive: true);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(sourceFile.path)}';
    final destPath = p.join(subDir.path, fileName);
    await sourceFile.copy(destPath);

    await MemoryDatabase.insertAttachment(Attachment(
      memoryId: memoryId,
      filePath: destPath,
      fileType: type,
      fileName: p.basename(sourceFile.path),
    ));
  }

  /// 导出所有记忆为 JSON 字符串
  String exportToJson() => MemoryService.exportToJson(memories);

  /// 获取所有标签（去重）
  List<String> get allTags => MemoryService.collectAllTags(memories);

  /// 云同步是否可用
  bool get cloudAvailable => CloudSyncService().isInitialized;

  /// 推送到云端
  Future<int> pushToCloud() async {
    if (!cloudAvailable) throw Exception('云同步未配置');
    return await CloudSyncService().pushMemories(memories);
  }

  /// 从云端拉取
  Future<int> pullFromCloud() async {
    if (!cloudAvailable) throw Exception('云同步未配置');
    final count = await CloudSyncService().pullMemories(memories);
    if (count > 0) await loadMemories();
    return count;
  }

  /// 导出完整备份（含附件 base64）到文件
  Future<String> exportToFile() async {
    final list = <Map<String, dynamic>>[];
    for (final m in memories) {
      final attachments = m.id != null
          ? await MemoryDatabase.getAttachments(m.id!)
          : <Attachment>[];
      final attList = <Map<String, dynamic>>[];
      for (final a in attachments) {
        final file = File(a.filePath);
        final bytes = await file.readAsBytes();
        attList.add({
          'file_name': a.fileName,
          'file_type': a.fileType,
          'data': base64Encode(bytes),
        });
      }
      list.add({
        'content': m.content,
        'date': m.date.toIso8601String(),
        'tags': m.tags,
        'attachments': attList,
      });
    }

    final encoder = const JsonEncoder.withIndent('  ');
    final json = encoder.convert(list);

    // 保存到 Downloads 目录
    String dirPath;
    try {
      dirPath = (await getDownloadsDirectory())!.path;
    } catch (_) {
      final appDir = await getApplicationDocumentsDirectory();
      dirPath = appDir.path;
    }

    final fileName =
        'memory_bottle_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final filePath = p.join(dirPath, fileName);
    await File(filePath).writeAsString(json);
    return filePath;
  }

  /// 从备份文件导入记忆和附件
  Future<int> importFromFile(String filePath) async {
    final jsonStr = await File(filePath).readAsString();
    final List<dynamic> list = jsonDecode(jsonStr);
    int imported = 0;

    for (final item in list) {
      final content = item['content'] as String;
      final date = DateTime.parse(item['date'] as String);
      final tags = item['tags'] as String? ?? '';

      // 去重检查（精确到秒）
      final exists = memories.any((m) {
        if (m.content != content) return false;
        return m.date.year == date.year &&
            m.date.month == date.month &&
            m.date.day == date.day &&
            m.date.hour == date.hour &&
            m.date.minute == date.minute &&
            m.date.second == date.second;
      });
      if (exists) continue;

      final memory = Memory(content: content, date: date, tags: tags);
      final id = await _memoryService.addMemory(memory);
      memory.id = id;

      // 导入附件
      final attData = item['attachments'] as List<dynamic>?;
      if (attData != null) {
        for (final a in attData) {
          final fileName = a['file_name'] as String;
          final fileType = a['file_type'] as String;
          final data = a['data'] as String;
          final bytes = base64Decode(data);

          final dir = await getApplicationDocumentsDirectory();
          final subDir =
              Directory(p.join(dir.path, 'attachments', id.toString()));
          if (!await subDir.exists()) {
            await subDir.create(recursive: true);
          }

          final destPath = p.join(subDir.path, fileName);
          await File(destPath).writeAsBytes(bytes);

          await MemoryDatabase.insertAttachment(Attachment(
            memoryId: id,
            filePath: destPath,
            fileType: fileType,
            fileName: fileName,
          ));
        }
      }

      imported++;
    }

    await loadMemories();
    return imported;
  }
}
