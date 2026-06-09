import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../providers/memory_provider.dart';
import '../models/memory.dart';
import '../models/attachment.dart';
import '../utils/date_utils.dart';

class WriteMemoryPage extends StatefulWidget {
  final Memory? memory;

  bool get isEditing => memory != null;

  const WriteMemoryPage({super.key, this.memory});

  @override
  State<WriteMemoryPage> createState() => _WriteMemoryPageState();
}

class _WriteMemoryPageState extends State<WriteMemoryPage> {
  late final TextEditingController _contentController;
  late final TextEditingController _tagsController;
  late DateTime _selectedDate;

  final List<File> _imageFiles = [];
  final List<File> _docFiles = [];
  List<Attachment>? _existingAttachments;
  bool _loadingAttachments = false;

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

    if (widget.isEditing && widget.memory!.id != null) {
      _loadExistingAttachments();
    }
  }

  Future<void> _loadExistingAttachments() async {
    setState(() => _loadingAttachments = true);
    _existingAttachments = await context
        .read<MemoryProvider>()
        .getAttachments(widget.memory!.id!);
    setState(() => _loadingAttachments = false);
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
    if (pickedDate != null) setState(() => _selectedDate = pickedDate);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(source: source, imageQuality: 85);
      if (xFile != null) {
        setState(() => _imageFiles.add(File(xFile.path)));
      }
    } catch (_) {}
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      if (result != null) {
        for (final file in result.files) {
          if (file.path == null) continue;
          final f = File(file.path!);
          final ext = file.extension?.toLowerCase() ?? '';
          // 图片扩展名归入图片类，其余归入文档类
          if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic']
              .contains(ext)) {
            _imageFiles.add(f);
          } else {
            _docFiles.add(f);
          }
        }
        setState(() {});
      }
    } catch (_) {}
  }

  void _removeImage(int index) {
    setState(() => _imageFiles.removeAt(index));
  }

  void _removeDoc(int index) {
    setState(() => _docFiles.removeAt(index));
  }

  void _showPickOptions() {
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('添加附件',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              if (isMobile) ...[
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('拍照'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('相册'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: Text(isMobile ? '选择文件' : '选择文件 / 图片'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFiles();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveMemory() async {
    final content = _contentController.text.trim();
    final tags = _tagsController.text.trim();

    if (content.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("请先写下一些内容")),
        );
      }
      return;
    }

    final provider = context.read<MemoryProvider>();

    if (widget.isEditing) {
      provider.updateMemory(widget.memory!, content, _selectedDate, tags);
    } else {
      await provider.addMemory(
        Memory(content: content, date: _selectedDate, tags: tags),
        imageFiles: _imageFiles.isNotEmpty ? _imageFiles : null,
        docFiles: _docFiles.isNotEmpty ? _docFiles : null,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = formatDate(_selectedDate);
    final isEditing = widget.isEditing;
    final title = isEditing ? '编辑记忆' : '写下记忆';
    final icon = isEditing ? Icons.edit : Icons.edit_note;
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
              Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                isEditing ? '修改这段记忆' : '记录这一刻',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),

              // ---- 内容 + 标签 + 日期 ----
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
                      _DateRow(
                          dateText: dateText, onPick: _pickDate),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---- 附件区域 ----
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.attach_file,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('附件',
                              style: Theme.of(context).textTheme.titleMedium),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _showPickOptions,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('添加'),
                          ),
                        ],
                      ),

                      // 已有附件（编辑模式）
                      if (_loadingAttachments)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),

                      if (_existingAttachments != null &&
                          _existingAttachments!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('已有附件：',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 6),
                        ...(_existingAttachments!.map((a) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(a.isImage ? Icons.image : Icons.description,
                                      size: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(a.fileName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ))),
                      ],

                      // 新选的图片缩略图
                      if (_imageFiles.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text('图片：',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(_imageFiles.length, (i) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _imageFiles[i],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, e, s) => Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey.shade200,
                                      child:
                                          const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: IconButton(
                                    icon: const Icon(Icons.cancel, size: 20),
                                    color: Colors.red,
                                    onPressed: () => _removeImage(i),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],

                      // 新选的文档列表
                      if (_docFiles.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text('文档：',
                            style: Theme.of(context).textTheme.bodySmall),
                        ...List.generate(_docFiles.length, (i) {
                          final name = _docFiles[i].path.split('/').last;
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.description, size: 20),
                            title: Text(name,
                                style: Theme.of(context).textTheme.bodyMedium),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => _removeDoc(i),
                            ),
                          );
                        }),
                      ],

                      if (_imageFiles.isEmpty &&
                          _docFiles.isEmpty &&
                          (_existingAttachments == null ||
                              _existingAttachments!.isEmpty))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text('还没有添加附件',
                              style: Theme.of(context).textTheme.bodyMedium),
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

/// 日期行组件
class _DateRow extends StatelessWidget {
  final String dateText;
  final VoidCallback onPick;
  const _DateRow({required this.dateText, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text('记忆时间：$dateText',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          TextButton(onPressed: onPick, child: const Text('修改')),
        ],
      ),
    );
  }
}
