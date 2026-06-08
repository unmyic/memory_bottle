import 'package:flutter_test/flutter_test.dart';
import 'package:memory_bottle/models/memory.dart';
import 'package:memory_bottle/services/memory_service.dart';

void main() {
  group('MemoryService.parseTags', () {
    test('splits comma-separated tags', () {
      final result = MemoryService.parseTags('工作, 学习, 想法');
      expect(result, ['工作', '学习', '想法']);
    });

    test('handles empty tags', () {
      final result = MemoryService.parseTags('');
      expect(result, isEmpty);
    });

    test('handles tags with extra spaces', () {
      final result = MemoryService.parseTags(' 焦虑 ,  夜晚  , 日记 ');
      expect(result, ['焦虑', '夜晚', '日记']);
    });

    test('filters out empty tags from trailing commas', () {
      final result = MemoryService.parseTags('工作, , 学习,');
      expect(result, ['工作', '学习']);
    });
  });

  group('MemoryService.collectAllTags', () {
    test('collects unique tags from all memories', () {
      final memories = [
        Memory(content: 'a', date: DateTime.now(), tags: '工作, 学习'),
        Memory(content: 'b', date: DateTime.now(), tags: '工作, 运动'),
        Memory(content: 'c', date: DateTime.now(), tags: ''),
      ];

      final tags = MemoryService.collectAllTags(memories);
      expect(tags.length, 3);
      expect(tags, containsAll(['工作', '学习', '运动']));
    });
  });

  group('MemoryService.searchMemories', () {
    late List<Memory> memories;

    setUp(() {
      memories = [
        Memory(
          id: 1,
          content: '今天学习 Flutter',
          date: DateTime(2025, 6, 1),
          tags: '编程, 学习',
        ),
        Memory(
          id: 2,
          content: '去公园跑步',
          date: DateTime(2025, 6, 3),
          tags: '运动',
        ),
        Memory(
          id: 3,
          content: '完成项目交付',
          date: DateTime(2025, 6, 5),
          tags: '工作, 项目',
        ),
      ];
    });

    test('returns all when keyword is empty', () {
      final result = MemoryService.searchMemories(memories, '');
      expect(result.length, 3);
    });

    test('searches by content', () {
      final result = MemoryService.searchMemories(memories, 'Flutter');
      expect(result.length, 1);
      expect(result.first.id, 1);
    });

    test('searches by tag', () {
      final result = MemoryService.searchMemories(memories, '运动');
      expect(result.length, 1);
      expect(result.first.id, 2);
    });

    test('searches by date', () {
      final result = MemoryService.searchMemories(memories, '03日');
      expect(result.length, 1);
      expect(result.first.id, 2);
    });

    test('returns empty when no match', () {
      final result = MemoryService.searchMemories(memories, '不存在');
      expect(result, isEmpty);
    });
  });

  group('MemoryService.exportToJson', () {
    test('exports memories as formatted JSON', () {
      final memories = [
        Memory(
          id: 1,
          content: '测试',
          date: DateTime(2025, 6, 8),
          tags: '日记',
        ),
      ];

      final json = MemoryService.exportToJson(memories);
      expect(json, contains('"content": "测试"'));
      expect(json, contains('"tags": "日记"'));
      expect(json.startsWith('['), isTrue);
      expect(json.trimRight().endsWith(']'), isTrue);
    });

    test('exports empty list', () {
      final json = MemoryService.exportToJson([]);
      expect(json.trim(), '[]');
    });
  });
}
