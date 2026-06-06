import 'package:flutter/material.dart';

import '../models/memory.dart';
import '../utils/date_utils.dart';

import 'write_memory_page.dart';
import 'memory_list_page.dart';
import 'bottle_page.dart';

class HomePage extends StatelessWidget {
  final List<Memory> memories;
  final Function(Memory) onAddMemory;
  final void Function(Memory memory) onDeleteMemory;
  final void Function(
    Memory memory,
    String newContent,
    DateTime newDate,
    String newTags,
  ) 
    onUpdateMemory;

  const HomePage({
    super.key,
    required this.memories,
    required this.onAddMemory,
    required this.onDeleteMemory,
    required this.onUpdateMemory,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount = memories.length;
    final earliestMemory = memories.isEmpty ? null : memories.last;
    final latestMemory = memories.isEmpty ? null : memories.first;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final bottleCount = memories.where((memory) {
      final memoryDay = DateTime(
        memory.date.year,
        memory.date.month,
        memory.date.day,
      );

      return memoryDay.isBefore(today);
    }).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("记忆漂流瓶"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "已保存 $totalCount 条记忆",
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 6),

            Text(
              "可拾取 $bottleCount 个漂流瓶",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            if (earliestMemory != null) ...[
              const SizedBox(height: 6),
              Text(
                "最早记忆：${formatDate(earliestMemory.date)}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            if (latestMemory != null) ...[
              const SizedBox(height: 6),
              Text(
                "最近记忆：${formatDate(latestMemory.date)}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WriteMemoryPage(
                      onSave: onAddMemory,
                    ),
                  ),
                );
              },
              child: const Text("写下记忆"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemoryListPage(
                      memories: memories,
                      onDeleteMemory: onDeleteMemory,
                      onUpdateMemory: onUpdateMemory,
                    ),
                  ),
                );
              },
              child: const Text("查看记忆"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: memories.isEmpty
                  ? null
                  : () {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);

                      final pastMemories = memories.where((memory) {
                        final memoryDay = DateTime(
                          memory.date.year,
                          memory.date.month,
                          memory.date.day,
                        );

                        return memoryDay.isBefore(today);
                      }).toList();

                      if (pastMemories.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("还没有可以拾取的过去记忆"),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BottlePage(
                            memories: pastMemories,
                            onDeleteMemory: onDeleteMemory,
                            onUpdateMemory: onUpdateMemory,
                          ),
                        ),
                      );
                    },
              child: const Text("拾取漂流瓶"),
            ),
          ],
        ),
      ),
    );
  }
}