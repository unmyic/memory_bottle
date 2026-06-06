import '../models/memory.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class MemoryDatabase {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'memory_bottle.db');

    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE memories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            date TEXT NOT NULL,
            tags TEXT NOT NULL DEFAULT ''
          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE memories ADD COLUMN tags TEXT NOT NULL DEFAULT ''",
          );
        }
      },
    );

    return _database!;
  }

    
  static Future<int> insertMemory(Memory memory) async {
    final db = await getDatabase();
    return await db.insert('memories', memory.toMap());
  }

  static Future<List<Memory>> getAllMemories() async {
    final db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(
      'memories',
      orderBy: 'date DESC',
    );

    return maps.map((map) => Memory.fromMap(map)).toList();
  }

  static Future<int> updateMemory(Memory memory) async {
    final db = await getDatabase();

    return await db.update(
      'memories',
      memory.toMap(),
      where: 'id = ?',
      whereArgs: [memory.id],
    );
  }

  static Future<int> deleteMemory(int id) async {
    final db = await getDatabase();

    return await db.delete(
      'memories',
      where: 'id = ?',
     whereArgs: [id],
    );
  }
}