import 'dart:math';

import 'package:flutter/material.dart';

import '../models/memory.dart';
import '../utils/date_utils.dart';

import 'memory_detail_page.dart';

class BottlePage extends StatefulWidget {
  final List<Memory> memories;

  final void Function(Memory memory) onDeleteMemory;
  final void Function(
    Memory memory,
    String newContent,
    DateTime newDate,
    String newTags,
  ) onUpdateMemory;

  const BottlePage({
    super.key,
    required this.memories,
    required this.onDeleteMemory,
    required this.onUpdateMemory,
  });

  @override
  State<BottlePage> createState() => _BottlePageState();
}

class _BottlePageState extends State<BottlePage> {
  late Memory currentMemory;
  late List<Memory> remainingMemories;

  @override
  void initState() {
    super.initState();
    remainingMemories = List.from(widget.memories);
    pickRandomMemory();
  }

  void pickRandomMemory() {
    final random = Random();
    final index = random.nextInt(remainingMemories.length);
    currentMemory = remainingMemories.removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = formatDate(currentMemory.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text("拾取漂流瓶"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    dateText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    currentMemory.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),   
                  const SizedBox(height: 24),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      daysAgoText(currentMemory.date),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),  
                  
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MemoryDetailPage(
                              memory: currentMemory,
                              onDeleteMemory: widget.onDeleteMemory,
                              onUpdateMemory: widget.onUpdateMemory,
                            ),
                          ),
                        ).then((deleted) {
                          if (deleted == true) {
                            if (remainingMemories.isNotEmpty) {
                              setState(() {
                                pickRandomMemory();
                              });
                            } else {
                              Navigator.pop(context);
                            }
                          } else {
                            setState(() {});
                          }
                        });
                      },
                      child: const Text("查看这条记忆详情"),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: remainingMemories.isEmpty
                        ? null
                        : () {
                            setState(() {
                              pickRandomMemory();
                            });
                          },
                      child: Text(
                        remainingMemories.isEmpty ? "已经没有新的漂流瓶了" : "再拾取一个",
                      ),
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
