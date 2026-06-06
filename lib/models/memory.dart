class Memory {
  int? id;
  String content;
  DateTime date;
  String tags;

  Memory({
    this.id,
    required this.content,
    required this.date,
    this.tags = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'date': date.toIso8601String(),
      'tags': tags,
    };
  }

  static Memory fromMap(Map<String, dynamic> map) {
    return Memory(
      id: map['id'],
      content: map['content'],
      date: DateTime.parse(map['date']),
      tags: map['tags'] ?? "",
    );
  }
}