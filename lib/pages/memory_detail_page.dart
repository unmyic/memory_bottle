import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/memory_provider.dart';
import '../models/memory.dart';
import '../models/attachment.dart';
import '../utils/date_utils.dart';
import '../widgets/memory_content_card.dart';

import 'write_memory_page.dart';

class MemoryDetailPage extends StatefulWidget {
  final Memory memory;

  const MemoryDetailPage({super.key, required this.memory});

  @override
  State<MemoryDetailPage> createState() => _MemoryDetailPageState();
}

class _MemoryDetailPageState extends State<MemoryDetailPage> {
  List<Attachment>? _attachments;

  @override
  void initState() {
    super.initState();
    _loadAttachments();
  }

  void _loadAttachments() async {
    if (widget.memory.id == null) return;
    final attachments =
        await context.read<MemoryProvider>().getAttachments(widget.memory.id!);
    if (mounted) setState(() => _attachments = attachments);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = formatDate(widget.memory.date);

    return Scaffold(
      appBar: AppBar(title: const Text("记忆详情")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MemoryContentCard(
                memory: widget.memory,
                dateText: dateText,
                attachments: _attachments,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WriteMemoryPage(memory: widget.memory),
                    ),
                  ).then((_) {
                    _loadAttachments();
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
                    builder: (ctx) => AlertDialog(
                      title: const Text("删除记忆"),
                      content: const Text("确定要删除这条记忆吗？"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("取消"),
                        ),
                        TextButton(
                          onPressed: () {
                            context
                                .read<MemoryProvider>()
                                .deleteMemory(widget.memory);
                            Navigator.pop(ctx);
                            Navigator.pop(context, true);
                          },
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.red),
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
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
