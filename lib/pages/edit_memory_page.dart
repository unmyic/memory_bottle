import 'package:flutter/material.dart';

import '../models/memory.dart';
import '../utils/date_utils.dart';

class EditMemoryPage extends StatefulWidget {
  final Memory memory;
  final void Function(
    Memory memory,
    String newContent,
    DateTime newDate,
    String newTags,
  ) onUpdateMemory;

  const EditMemoryPage({
    super.key,
    required this.memory,
    required this.onUpdateMemory,
  });

  @override
  State<EditMemoryPage> createState() => _EditMemoryPageState();
}

class _EditMemoryPageState extends State<EditMemoryPage> {
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    _contentController = TextEditingController(
      text: widget.memory.content,
    );

    _tagsController = TextEditingController(
      text: widget.memory.tags,
    );

    _selectedDate = widget.memory.date;
  }

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

  void _saveEdit() {
    final content = _contentController.text.trim();
    final tags = _tagsController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("记忆内容不能为空"),
        ),
      );
      return;
    }

    widget.onUpdateMemory(
      widget.memory,
      content,
      _selectedDate,
      tags,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = formatDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("编辑记忆"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.edit,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 12),

              Text(
                "修改这段记忆",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 8),

              Text(
                "你可以更新内容、标签或记忆发生的时间",
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
                          labelText: "记忆内容",
                          hintText: "修改你想保存的记忆内容……",
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
                onPressed: _saveEdit,
                icon: const Icon(Icons.check),
                label: const Text("保存修改"),
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