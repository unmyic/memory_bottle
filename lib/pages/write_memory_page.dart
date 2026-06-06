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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "这一刻，你想记下什么？",
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "标签，例如：焦虑, 工作, 夜晚",
              ),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Text("记忆时间：$dateText"),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text("修改日期"),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveMemory,
                child: const Text("保存记忆"),
              ), 
            ),
          ],
        ),
      ),
    );
  }
}
