import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/memory_provider.dart';
import '../models/memory.dart';
import '../utils/date_utils.dart';

class WriteMemoryPage extends StatefulWidget {
  final Memory? memory;

  bool get isEditing => memory != null;

  const WriteMemoryPage({
    super.key,
    this.memory,
  });

  @override
  State<WriteMemoryPage> createState() => _WriteMemoryPageState();
}

class _WriteMemoryPageState extends State<WriteMemoryPage> {
  late final TextEditingController _contentController;
  late final TextEditingController _tagsController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    _contentController = TextEditingController(
      text: widget.isEditing ? widget.memory!.content : '',
    );
    _tagsController = TextEditingController(
      text: widget.isEditing ? widget.memory!.tags : '',
    );
    _selectedDate = widget.isEditing ? widget.memory!.date : DateTime.now();
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

  void _saveMemory() {
    final content = _contentController.text.trim();
    final tags = _tagsController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请先写下一些内容")),
      );
      return;
    }

    final provider = context.read<MemoryProvider>();

    if (widget.isEditing) {
      provider.updateMemory(widget.memory!, content, _selectedDate, tags);
    } else {
      provider.addMemory(
        Memory(content: content, date: _selectedDate, tags: tags),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = formatDate(_selectedDate);
    final isEditing = widget.isEditing;

    final icon = isEditing ? Icons.edit : Icons.edit_note;
    final title = isEditing ? '编辑记忆' : '写下记忆';
    final subtitle = isEditing
        ? '你可以更新内容、标签或记忆发生的时间'
        : '写下想保存的心情、事件或回忆';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                icon,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                isEditing ? '修改这段记忆' : '记录这一刻',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
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
                        decoration: InputDecoration(
                          labelText: isEditing ? '记忆内容' : '这一刻，你想记下什么？',
                          hintText: isEditing
                              ? '修改你想保存的记忆内容……'
                              : '例如：今天终于完成了一个重要的小目标……',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: '标签',
                          hintText: '例如：焦虑, 工作, 夜晚',
                          prefixIcon: Icon(Icons.sell_outlined),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12,
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
                                '记忆时间：$dateText',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: _pickDate,
                              child: const Text('修改'),
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
                label: Text(isEditing ? '保存修改' : '保存记忆'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
