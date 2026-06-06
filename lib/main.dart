import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database/memory_database.dart';
import 'models/memory.dart';
import 'pages/home_page.dart';
void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MemoryBottleApp());
}

class MemoryBottleApp extends StatefulWidget {
  const MemoryBottleApp({super.key});

  @override
  State<MemoryBottleApp> createState() => _MemoryBottleAppState();
}

class _MemoryBottleAppState extends State<MemoryBottleApp> {
  final List<Memory> memories = [];

  @override
  void initState() {
    super.initState();
    loadMemories();
  }

  Future<void> loadMemories() async {
    final loadedMemories = await MemoryDatabase.getAllMemories();

    setState(() {
      memories.clear();
      memories.addAll(loadedMemories);
    });
  }
  
  Future<void> addMemory(Memory memory) async {
    final id = await MemoryDatabase.insertMemory(memory);
    memory.id = id;

    setState(() {
      memories.add(memory);
      memories.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> deleteMemory(Memory memory) async {
    if (memory.id != null) {
      await MemoryDatabase.deleteMemory(memory.id!);
    }

    setState(() {
      memories.remove(memory);
    });
  }

  Future<void> updateMemory(
    Memory memory,
    String newContent,
    DateTime newDate,
    String newTags,
  ) async {
    memory.content = newContent;
    memory.date = newDate;
    memory.tags = newTags;

    await MemoryDatabase.updateMemory(memory);

    setState(() {
      memories.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '记忆漂流瓶',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamilyFallback: const [
          'Microsoft YaHei',
          'SimHei',
          'Arial',
        ],
      ),
      home: HomePage(
        memories: memories,
        onAddMemory: addMemory,
        onDeleteMemory: deleteMemory,
        onUpdateMemory: updateMemory,
      ),
    );
  }
}
