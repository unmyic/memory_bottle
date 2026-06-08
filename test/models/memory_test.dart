import 'package:flutter_test/flutter_test.dart';
import 'package:memory_bottle/models/memory.dart';

void main() {
  group('Memory Model', () {
    test('toMap returns correct map without id', () {
      final memory = Memory(
        content: '测试内容',
        date: DateTime(2025, 6, 8),
        tags: '测试, 日记',
      );

      final map = memory.toMap();
      expect(map['content'], '测试内容');
      expect(map['tags'], '测试, 日记');
      expect(map['date'], contains('2025-06-08'));
      expect(map['id'], isNull);
    });

    test('toMap includes id when set', () {
      final memory = Memory(
        id: 42,
        content: '有 ID 的记忆',
        date: DateTime(2024, 1, 15),
        tags: '',
      );

      final map = memory.toMap();
      expect(map['id'], 42);
    });

    test('fromMap creates correct Memory', () {
      final map = {
        'id': 7,
        'content': '从数据库读取',
        'date': '2025-03-20T10:30:00.000',
        'tags': '工作, 想法',
      };

      final memory = Memory.fromMap(map);
      expect(memory.id, 7);
      expect(memory.content, '从数据库读取');
      expect(memory.date.year, 2025);
      expect(memory.date.month, 3);
      expect(memory.date.day, 20);
      expect(memory.tags, '工作, 想法');
    });

    test('fromMap handles null tags', () {
      final map = {
        'id': 1,
        'content': '无标签',
        'date': '2025-01-01T00:00:00.000',
      };

      final memory = Memory.fromMap(map);
      expect(memory.tags, '');
    });

    test('fromMap handles null id', () {
      final map = {
        'content': '新记忆',
        'date': '2025-05-01T00:00:00.000',
        'tags': '',
      };

      final memory = Memory.fromMap(map);
      expect(memory.id, isNull);
    });

    test('default tags is empty string', () {
      final memory = Memory(
        content: '无标签测试',
        date: DateTime.now(),
      );

      expect(memory.tags, '');
    });
  });
}
