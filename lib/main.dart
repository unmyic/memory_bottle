import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'services/memory_service.dart';
import 'models/memory.dart';
import 'pages/home_page.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MemoryBottleApp());
}

class MemoryBottleApp extends StatefulWidget {
  const MemoryBottleApp({super.key});

  @override
  State<MemoryBottleApp> createState() => _MemoryBottleAppState();
}

class _MemoryBottleAppState extends State<MemoryBottleApp> {
  final MemoryService _memoryService = MemoryService();
  final List<Memory> memories = [];

  @override
  void initState() {
    super.initState();
    loadMemories();
  }

  Future<void> loadMemories() async {
    final loadedMemories = await _memoryService.getAllMemories();

    setState(() {
      memories.clear();
      memories.addAll(loadedMemories);
    });
  }
  
  Future<void> addMemory(Memory memory) async {
    final id = await _memoryService.addMemory(memory);
    memory.id = id;

    setState(() {
      memories.add(memory);
      memories.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> deleteMemory(Memory memory) async {
    if (memory.id != null) {
      await _memoryService.deleteMemory(memory.id!);
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

    await _memoryService.updateMemory(memory);

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

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8EC5FF),
          brightness: Brightness.light,
          primary: const Color(0xFF5BA7E8),
          secondary: const Color(0xFF9BD7F5),
          surface: const Color(0xFFF5FBFF),
        ),

        scaffoldBackgroundColor: const Color(0xFFF5FBFF),

        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFFF5FBFF),
          foregroundColor: Color(0xFF243447),
          elevation: 0,
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5BA7E8),
            foregroundColor: Colors.white,
            minimumSize: const Size(120, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFD8EAF8),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF5BA7E8),
              width: 1.5,
            ),
          ),
        ),
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
