import 'package:flutter/foundation.dart';

import '../models/memory.dart';
import '../services/memory_service.dart';

class MemoryProvider extends ChangeNotifier {
  final MemoryService _memoryService = MemoryService();

  List<Memory> memories = [];
  bool isLoading = false;
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
  }

  Future<void> addMemory(Memory memory) async {
    try {
      final id = await _memoryService.addMemory(memory);
      memory.id = id;

      memories.add(memory);
      memories.sort((a, b) => b.date.compareTo(a.date));
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = '保存记忆失败，请重试';
      notifyListeners();
    }
  }

  Future<void> deleteMemory(Memory memory) async {
    try {
      if (memory.id != null) {
        await _memoryService.deleteMemory(memory.id!);
      }

      memories.remove(memory);
      errorMessage = null;
      notifyListeners();
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
    } catch (e) {
      errorMessage = '更新记忆失败，请重试';
      notifyListeners();
    }
  }

  /// 导出所有记忆为 JSON 字符串
  String exportToJson() => MemoryService.exportToJson(memories);

  /// 获取所有标签（去重）
  List<String> get allTags => MemoryService.collectAllTags(memories);
}
