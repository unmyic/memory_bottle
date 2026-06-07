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
  ) 
    onUpdateMemory;

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
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateText,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 12),

                  TagText(tags: widget.memory.tags),

                  const SizedBox(height: 20),
                  Text(
                    widget.memory.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMemoryPage(
                              memory: widget.memory,
                              onUpdateMemory: widget. onUpdateMemory,
                            ),
                          ),
                        ).then((_) {
                          setState(() {});
                        });
                      },
                      child: const Text("编辑这条记忆"),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
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
                                  Navigator.pop(context); // 关闭对话框
                                  Navigator.pop(context,true); // 返回上一页
                                },
                                child: const Text("删除"),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("删除这条记忆"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
