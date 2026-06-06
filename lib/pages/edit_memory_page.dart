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
  )
      onUpdateMemory;

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
        const SnackBar(content: Text("记忆内容不能为空")),
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "修改记忆内容",
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
                onPressed: _saveEdit,
                child: const Text("保存修改"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}