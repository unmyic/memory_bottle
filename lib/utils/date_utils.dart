String formatDate(DateTime date) {
  final year = date.year;
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return "$year年$month月$day日";
}

String daysAgoText(DateTime date) {
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final targetDay = DateTime(date.year, date.month, date.day);

  final days = today.difference(targetDay).inDays;

  if (days == 0) {
    return "这是今天的你";
  } else if (days > 0) {
    return "这是 $days 天前的你";
  } else {
    return "这是 ${-days} 天后的你";
  }
}

String seasonText(DateTime date) {
  final month = date.month;

  if (month >= 3 && month <= 5) {
    return "春季";
  } else if (month >= 6 && month <= 8) {
    return "夏季";
  } else if (month >= 9 && month <= 11) {
    return "秋季";
  } else {
    return "冬季";
  }
}

String monthGroupTitle(DateTime date) {
  final year = date.year;
  final month = date.month.toString().padLeft(2, '0');
  final season = seasonText(date);

  return "$year年 · $season · $month月";
}
