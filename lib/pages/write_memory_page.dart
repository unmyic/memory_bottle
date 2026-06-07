import 'package:flutter/material.dart';

import '../models/memory.dart';
import '../utils/date_utils.dart';

class WriteMemoryPage extends StatefulWidget {
  final void Function(Memory memory) onSave;

  const WriteMemoryPage({
    super.key,
    required this.onSave,
  });

  @override
  State<WriteMemoryPage> createState() => _WriteMemoryPageState();
}

class _WriteMemoryPageState extends State<WriteMemoryPage> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveMemory() {
    final content = _contentController.text.trim();
    final tags = _tagsController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("请先写下一些内容"),
        ),
      );
      return;
    }

    widget.onSave(
      Memory(
        content: content,
        date: _selectedDate,
        tags: tags,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = formatDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("写下记忆"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.edit_note,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 12),

              Text(
                "记录这一刻",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 8),

              Text(
                "写下想保存的心情、事件或回忆",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
              ),

              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _contentController,
                        maxLines: 9,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          labelText: "这一刻，你想记下什么？",
                          hintText: "例如：今天终于完成了一个重要的小目标……",
                          alignLabelWithHint: true,
                        ),
                      ),

                      const SizedBox(height: 18),

                      TextField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: "标签",
                          hintText: "例如：焦虑, 工作, 夜晚",
                          prefixIcon: Icon(Icons.sell_outlined),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "记忆时间：$dateText",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: _pickDate,
                              child: const Text("修改"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _saveMemory,
                icon: const Icon(Icons.check),
                label: const Text("保存记忆"),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("取消"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}