import '../models/memory.dart';
import '../models/attachment.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class MemoryDatabase {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    try {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'memory_bottle.db');

      _database = await openDatabase(
        path,
        version: 3,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE memories (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              content TEXT NOT NULL,
              date TEXT NOT NULL,
              tags TEXT NOT NULL DEFAULT ''
            )
          ''');
          await db.execute('''
            CREATE TABLE attachments (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              memory_id INTEGER NOT NULL,
              file_path TEXT NOT NULL,
              file_type TEXT NOT NULL,
              file_name TEXT NOT NULL,
              FOREIGN KEY (memory_id) REFERENCES memories(id) ON DELETE CASCADE
            )
          ''');
        },

        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute(
              "ALTER TABLE memories ADD COLUMN tags TEXT NOT NULL DEFAULT ''",
            );
          }
          if (oldVersion < 3) {
            await db.execute('''
              CREATE TABLE attachments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                memory_id INTEGER NOT NULL,
                file_path TEXT NOT NULL,
                file_type TEXT NOT NULL,
                file_name TEXT NOT NULL,
                FOREIGN KEY (memory_id) REFERENCES memories(id) ON DELETE CASCADE
              )
            ''');
          }
        },
      );

      return _database!;
    } catch (e) {
      throw Exception('数据库初始化失败：$e');
    }
  }

  // ---- 记忆 CRUD ----

  static Future<int> insertMemory(Memory memory) async {
    try {
      final db = await getDatabase();
      return await db.insert('memories', memory.toMap());
    } catch (e) {
      throw Exception('保存记忆失败：$e');
    }
  }

  static Future<List<Memory>> getAllMemories() async {
    try {
      final db = await getDatabase();
      final List<Map<String, dynamic>> maps = await db.query(
        'memories',
        orderBy: 'date DESC',
      );
      return maps.map((map) => Memory.fromMap(map)).toList();
    } catch (e) {
      throw Exception('读取记忆失败：$e');
    }
  }

  static Future<int> updateMemory(Memory memory) async {
    try {
      final db = await getDatabase();
      return await db.update(
        'memories',
        memory.toMap(),
        where: 'id = ?',
        whereArgs: [memory.id],
      );
    } catch (e) {
      throw Exception('更新记忆失败：$e');
    }
  }

  static Future<int> deleteMemory(int id) async {
    try {
      final db = await getDatabase();
      // 级联删除附件
      await db.delete('attachments', where: 'memory_id = ?', whereArgs: [id]);
      return await db.delete('memories', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('删除记忆失败：$e');
    }
  }

  // ---- 附件 CRUD ----

  static Future<int> insertAttachment(Attachment a) async {
    final db = await getDatabase();
    return await db.insert('attachments', a.toMap());
  }

  static Future<List<Attachment>> getAttachments(int memoryId) async {
    final db = await getDatabase();
    final maps = await db.query(
      'attachments',
      where: 'memory_id = ?',
      whereArgs: [memoryId],
      orderBy: 'id ASC',
    );
    return maps.map((m) => Attachment.fromMap(m)).toList();
  }

  static Future<void> deleteAttachment(int id) async {
    final db = await getDatabase();
    await db.delete('attachments', where: 'id = ?', whereArgs: [id]);
  }
}
