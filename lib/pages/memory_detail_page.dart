import 'package:flutter/material.dart';

import '../models/memory.dart';
import '../utils/date_utils.dart';
import '../widgets/tag_text.dart';

import 'edit_memory_page.dart';

class MemoryDetailPage extends StatefulWidget {
  final Memory memory;
  final void Function(Memory memory) onDeleteMemory;
  final void Function(
    Memory memory,
    String newContent,
    DateTime newDate,
    String newTags,
  ) onUpdateMemory;

  const MemoryDetailPage({
    super.key,
    required this.memory,
    required this.onDeleteMemory,
    required this.onUpdateMemory,
  });

  @override
  State<MemoryDetailPage> createState() => _MemoryDetailPageState();
}

class _MemoryDetailPageState extends State<MemoryDetailPage> {
  @override
  Widget build(BuildContext context) {
    final dateText = formatDate(widget.memory.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text("记忆详情"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateText,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      TagText(tags: widget.memory.tags),

                      const SizedBox(height: 20),

                      Divider(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.18),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        widget.memory.content,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.75,
                              fontSize: 17,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMemoryPage(
                        memory: widget.memory,
                        onUpdateMemory: widget.onUpdateMemory,
                      ),
                    ),
                  ).then((_) {
                    setState(() {});
                  });
                },
                icon: const Icon(Icons.edit_note),
                label: const Text("编辑这条记忆"),
              ),

              const SizedBox(height: 14),

              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("删除记忆"),
                      content: const Text("确定要删除这条记忆吗？"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("取消"),
                        ),
                        TextButton(
                          onPressed: () {
                            widget.onDeleteMemory(widget.memory);
                            Navigator.pop(context);
                            Navigator.pop(context, true);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text("删除"),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text("删除这条记忆"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(120, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}