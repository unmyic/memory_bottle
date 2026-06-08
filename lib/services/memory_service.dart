import '../database/memory_database.dart';
import '../models/memory.dart';

class MemoryService {
  Future<List<Memory>> getAllMemories() async {
    return await MemoryDatabase.getAllMemories();
  }

  Future<int> addMemory(Memory memory) async {
    return await MemoryDatabase.insertMemory(memory);
  }

  Future<int> updateMemory(Memory memory) async {
    return await MemoryDatabase.updateMemory(memory);
  }

  Future<int> deleteMemory(int id) async {
    return await MemoryDatabase.deleteMemory(id);
  }

  /// 解析逗号分隔的标签字符串为列表
  static List<String> parseTags(String tags) {
    return tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  /// 从记忆中提取所有去重的标签
  static List<String> collectAllTags(List<Memory> memories) {
    return memories
        .expand((m) => parseTags(m.tags))
        .toSet()
        .toList();
  }

  /// 搜索记忆（按内容、标签、日期）
  static List<Memory> searchMemories(
    List<Memory> memories,
    String keyword,
  ) {
    if (keyword.isEmpty) return memories;

    return memories.where((memory) {
      final matchesContent = memory.content.contains(keyword);
      final matchesTags = memory.tags.contains(keyword);

      final dateStr =
          '${memory.date.year}年${memory.date.month.toString().padLeft(2, '0')}月${memory.date.day.toString().padLeft(2, '0')}日';
      final matchesDate = dateStr.contains(keyword);

      return matchesContent || matchesTags || matchesDate;
    }).toList();
  }

  /// 导出记忆为 JSON 字符串
  static String exportToJson(List<Memory> memories) {
    if (memories.isEmpty) return '[]';

    final list = memories.map((m) => m.toMap()).toList();
    final buffer = StringBuffer();
    buffer.writeln('[');
    for (var i = 0; i < list.length; i++) {
      buffer.write('  ${_mapToJson(list[i])}');
      if (i < list.length - 1) buffer.writeln(',');
    }
    buffer.writeln();
    buffer.write(']');
    return buffer.toString();
  }

  static String _mapToJson(Map<String, dynamic> map) {
    final parts = <String>[];
    map.forEach((key, value) {
      final escaped = value.toString().replaceAll('"', '\\"');
      parts.add('"$key": "$escaped"');
    });
    return '{${parts.join(', ')}}';
  }
}
