import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../config/supabase_config.dart';
import '../models/memory.dart';
import '../models/attachment.dart';
import '../database/memory_database.dart';

class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._();
  factory CloudSyncService() => _instance;
  CloudSyncService._();

  SupabaseClient? _client;
  bool _initialized = false;

  SupabaseClient get client {
    if (_client == null) {
      throw StateError('CloudSyncService 未初始化，请先调用 initialize()');
    }
    return _client!;
  }

  bool get isInitialized => _initialized && _client != null;

  Future<void> initialize() async {
    if (_initialized) return;

    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );

    _client = Supabase.instance.client;
    _initialized = true;
  }

  /// 当前用户邮箱（未登录返回 null）
  String? get userEmail => _client?.auth.currentUser?.email;

  /// 是否已登录
  bool get isLoggedIn => _client?.auth.currentUser != null;

  /// 退出登录
  Future<void> signOut() async {
    await _client?.auth.signOut();
  }

  /// 比较两个 DateTime 是否相等（精确到秒，避免 TIMESTAMPTZ 精度/时区差异）
  static bool _dateEqual(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute &&
        a.second == b.second;
  }

  /// 推送单条记忆到云端（含附件）
  Future<bool> pushMemory(Memory m) async {
    // 检查云端是否已存在（按 content + date 去重）
    final existing = await client
        .from('memories')
        .select('id')
        .eq('content', m.content)
        .eq('date', m.date.toIso8601String());

    if (existing.isNotEmpty) return false;

    // 插入记忆
    final response = await client.from('memories').insert({
      'content': m.content,
      'date': m.date.toIso8601String(),
      'tags': m.tags,
    }).select('id');

    if (response.isEmpty) return false;
    final cloudMemoryId = response.first['id'] as int;

    // 上传附件
    if (m.id != null) {
      final attachments = await MemoryDatabase.getAttachments(m.id!);
      for (final a in attachments) {
        final file = File(a.filePath);
        if (!await file.exists()) continue;

        final storagePath = '$cloudMemoryId/${a.fileName}';
        await client.storage.from('attachments').upload(
              storagePath,
              file,
              fileOptions: const FileOptions(upsert: true),
            );

        await client.from('attachments').insert({
          'memory_id': cloudMemoryId,
          'file_name': a.fileName,
          'file_type': a.fileType,
          'storage_path': storagePath,
        });
      }
    }

    return true;
  }

  /// 从云端删除单条记忆
  Future<void> deleteMemory(String content, DateTime date) async {
    final results = await client
        .from('memories')
        .select('id')
        .eq('content', content)
        .eq('date', date.toIso8601String());

    for (final r in results) {
      final id = r['id'] as int;
      // 删除 Storage 中的附件
      final atts = await client
          .from('attachments')
          .select('storage_path')
          .eq('memory_id', id);
      final paths = <String>[];
      for (final a in atts) {
        paths.add(a['storage_path'] as String);
      }
      if (paths.isNotEmpty) {
        await client.storage.from('attachments').remove(paths);
      }
      // 删除记忆（CASCADE 自动删 attachments 表记录）
      await client.from('memories').delete().eq('id', id);
    }
  }

  /// 推送所有本地记忆到云端
  Future<int> pushMemories(List<Memory> localMemories) async {
    int uploaded = 0;

    for (final m in localMemories) {
      final ok = await pushMemory(m);
      if (ok) uploaded++;
    }

    return uploaded;
  }

  /// 从云端拉取记忆并合并到本地
  Future<int> pullMemories(List<Memory> localMemories) async {
    int downloaded = 0;

    // 获取所有云端记忆
    final cloudMemories = await client
        .from('memories')
        .select('*')
        .order('date', ascending: false);

    for (final cm in cloudMemories) {
      final content = cm['content'] as String;
      final date = DateTime.parse(cm['date'] as String);
      final tags = cm['tags'] as String? ?? '';
      final cloudId = cm['id'] as int;

      // 去重（比较日期到秒，避免 TIMESTAMPTZ 往返精度/时区差异）
      final exists = localMemories.any((m) {
        if (m.content != content) return false;
        return _dateEqual(m.date, date);
      });
      if (exists) continue;

      // 插入本地
      final memory = Memory(content: content, date: date, tags: tags);
      final localId = await MemoryDatabase.insertMemory(memory);

      // 下载附件
      final cloudAttachments = await client
          .from('attachments')
          .select('*')
          .eq('memory_id', cloudId);

      for (final ca in cloudAttachments) {
        final fileName = ca['file_name'] as String;
        final fileType = ca['file_type'] as String;
        final storagePath = ca['storage_path'] as String;

        try {
          final fileBytes =
              await client.storage.from('attachments').download(storagePath);

          final dir = await getApplicationDocumentsDirectory();
          final subDir =
              Directory(p.join(dir.path, 'attachments', localId.toString()));
          if (!await subDir.exists()) {
            await subDir.create(recursive: true);
          }

          final destPath = p.join(subDir.path, fileName);
          await File(destPath).writeAsBytes(fileBytes);

          await MemoryDatabase.insertAttachment(Attachment(
            memoryId: localId,
            filePath: destPath,
            fileType: fileType,
            fileName: fileName,
          ));
        } catch (_) {
          // 附件下载失败不阻塞导入
        }
      }

      downloaded++;
    }

    return downloaded;
  }
}
