class Attachment {
  int? id;
  int memoryId;
  String filePath;
  String fileType; // 'image' / 'document'
  String fileName;

  Attachment({
    this.id,
    required this.memoryId,
    required this.filePath,
    required this.fileType,
    required this.fileName,
  });

  bool get isImage => fileType == 'image';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memory_id': memoryId,
      'file_path': filePath,
      'file_type': fileType,
      'file_name': fileName,
    };
  }

  static Attachment fromMap(Map<String, dynamic> map) {
    return Attachment(
      id: map['id'],
      memoryId: map['memory_id'],
      filePath: map['file_path'],
      fileType: map['file_type'],
      fileName: map['file_name'] ?? '',
    );
  }
}
