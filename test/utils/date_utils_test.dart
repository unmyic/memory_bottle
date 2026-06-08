import 'package:flutter_test/flutter_test.dart';
import 'package:memory_bottle/utils/date_utils.dart';

void main() {
  group('formatDate', () {
    test('formats date correctly', () {
      final date = DateTime(2025, 6, 8);
      expect(formatDate(date), '2025年06月08日');
    });

    test('pads single-digit month and day', () {
      final date = DateTime(2025, 1, 5);
      expect(formatDate(date), '2025年01月05日');
    });
  });

  group('daysAgoText', () {
    test('returns today text for current date', () {
      final now = DateTime.now();
      expect(daysAgoText(now), '这是今天的你');
    });

    test('returns days ago text', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 3));
      expect(daysAgoText(yesterday), '这是 3 天前的你');
    });
  });

  group('seasonText', () {
    test('returns spring for months 3-5', () {
      expect(seasonText(DateTime(2025, 3, 1)), '春季');
      expect(seasonText(DateTime(2025, 4, 15)), '春季');
      expect(seasonText(DateTime(2025, 5, 31)), '春季');
    });

    test('returns summer for months 6-8', () {
      expect(seasonText(DateTime(2025, 6, 1)), '夏季');
      expect(seasonText(DateTime(2025, 7, 15)), '夏季');
      expect(seasonText(DateTime(2025, 8, 31)), '夏季');
    });

    test('returns autumn for months 9-11', () {
      expect(seasonText(DateTime(2025, 9, 1)), '秋季');
      expect(seasonText(DateTime(2025, 10, 15)), '秋季');
      expect(seasonText(DateTime(2025, 11, 30)), '秋季');
    });

    test('returns winter for months 12, 1, 2', () {
      expect(seasonText(DateTime(2025, 12, 1)), '冬季');
      expect(seasonText(DateTime(2025, 1, 15)), '冬季');
      expect(seasonText(DateTime(2025, 2, 28)), '冬季');
    });
  });

  group('monthGroupTitle', () {
    test('returns correctly formatted group title', () {
      final date = DateTime(2025, 6, 8);
      final title = monthGroupTitle(date);
      expect(title, contains('2025年'));
      expect(title, contains('夏季'));
      expect(title, contains('06月'));
    });
  });
}
