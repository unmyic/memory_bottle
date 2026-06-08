import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/memory_provider.dart';
import '../widgets/settings_sheet.dart';
import '../utils/date_utils.dart';

import 'write_memory_page.dart';
import 'memory_list_page.dart';
import 'bottle_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemoryProvider>();
    final memories = provider.memories;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: '设置',
            onPressed: () => showSettingsSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: '导出记忆',
            onPressed: () => _exportMemories(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            Icon(
              Icons.sailing,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 8),

            Text(
              "如果连你也忘了",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 30),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "记忆统计",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      "已保存 $totalCount 条记忆",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "可拾取 $bottleCount 个漂流瓶",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),

                    if (earliestMemory != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "最早记忆：${formatDate(earliestMemory.date)}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),

                    if (latestMemory != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "最近记忆：${formatDate(latestMemory.date)}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WriteMemoryPage(),
                  ),
                );
              },
              icon: const Icon(Icons.edit_note),
              label: const Text("写下记忆"),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MemoryListPage(),
                  ),
                );
              },
              icon: const Icon(Icons.library_books_outlined),
              label: const Text("查看记忆"),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
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
                          builder: (_) => BottlePage(
                            memories: pastMemories,
                          ),
                        ),
                      );
                    },
              icon: const Icon(Icons.waves_outlined),
              label: const Text("拾取漂流瓶"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _exportMemories(BuildContext context) {
    final provider = context.read<MemoryProvider>();
    final json = provider.exportToJson();
    Clipboard.setData(ClipboardData(text: json));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已复制 ${provider.memories.length} 条记忆到剪贴板'),
        ),
      );
    }
  }
}
