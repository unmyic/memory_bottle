import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MemoryBottleApp());
}

class Memory {
  int? id;
  String content;
  DateTime date;

  Memory({
    this.id,
    required this.content,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'date': date.toIso8601String(),
    };
  }

  static Memory fromMap(Map<String, dynamic> map) {
    return Memory(
      id: map['id'] as int?,
      content: map['content'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }
}

class MemoryDatabase {
  static File? _dataFile;
  static int _nextId = 1;

  /// 获取数据文件路径，存储在用户文档目录下
  static File _getDataFile() {
    if (_dataFile != null) return _dataFile!;

    String dataDir;
    if (Platform.isWindows) {
      dataDir = '${Platform.environment['USERPROFILE']}\\Documents\\MemoryBottle';
    } else if (Platform.isMacOS) {
      dataDir = '${Platform.environment['HOME']}/Documents/MemoryBottle';
    } else if (Platform.isLinux) {
      dataDir = '${Platform.environment['HOME']}/.local/share/MemoryBottle';
    } else {
      // Android/iOS - 使用应用私有目录 (实际应由 path_provider 提供，这里给个备用方案)
      dataDir = '${Platform.environment['HOME']}/.memory_bottle';
    }

    final dir = Directory(dataDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    _dataFile = File('$dataDir/memory_bottle.json');

    // 首次运行时创建空文件
    if (!_dataFile!.existsSync()) {
      _dataFile!.writeAsStringSync('[]');
    }

    return _dataFile!;
  }

  static List<Map<String, dynamic>> _readAll() {
    final file = _getDataFile();
    final content = file.readAsStringSync();
    final List<dynamic> jsonList = jsonDecode(content);
    return jsonList.cast<Map<String, dynamic>>();
  }

  static void _writeAll(List<Map<String, dynamic>> data) {
    final file = _getDataFile();
    file.writeAsStringSync(jsonEncode(data));
  }

  static int insertMemory(Memory memory) {
    final data = _readAll();

    // 找到最大 ID 用于生成新 ID
    int maxId = 0;
    for (final item in data) {
      final id = item['id'] as int?;
      if (id != null && id > maxId) maxId = id;
    }
    _nextId = maxId + 1;

    memory.id = _nextId;
    data.add(memory.toMap());
    _writeAll(data);

    return _nextId;
  }

  static List<Memory> getAllMemories() {
    final data = _readAll();
    final memories = data.map((map) => Memory.fromMap(map)).toList();
    // 按日期降序排序
    memories.sort((a, b) => b.date.compareTo(a.date));
    return memories;
  }

  static void updateMemory(Memory memory) {
    final data = _readAll();
    final index = data.indexWhere((item) => item['id'] == memory.id);

    if (index != -1) {
      data[index] = memory.toMap();
      _writeAll(data);
    }
  }

  static void deleteMemory(int id) {
    final data = _readAll();
    data.removeWhere((item) => item['id'] == id);
    _writeAll(data);
  }

  /// 导出数据，返回导出文件路径
  static String exportDatabase() {
    final sourceFile = _getDataFile();

    // 导出到桌面
    String desktopDir;
    if (Platform.isWindows) {
      desktopDir = '${Platform.environment['USERPROFILE']}\\Desktop';
    } else {
      desktopDir = '${Platform.environment['HOME']}/Desktop';
    }

    final timestamp =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
    final exportPath = '$desktopDir/记忆漂流瓶_备份_$timestamp.json';

    sourceFile.copySync(exportPath);
    return exportPath;
  }

  /// 从 JSON 文件导入数据（替换当前数据），返回导入的记忆数量
  static int importDatabase(String importFilePath) {
    final importFile = File(importFilePath);
    final content = importFile.readAsStringSync();
    final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;

    final targetFile = _getDataFile();
    targetFile.writeAsStringSync(jsonEncode(jsonList));

    return jsonList.length;
  }
}

class MemoryBottleApp extends StatefulWidget {
  const MemoryBottleApp({super.key});

  @override
  State<MemoryBottleApp> createState() => _MemoryBottleAppState();
}

class _MemoryBottleAppState extends State<MemoryBottleApp> {
  final List<Memory> memories = [];

  @override
  void initState() {
    super.initState();
    loadMemories();
  }

  void loadMemories() {
    final loadedMemories = MemoryDatabase.getAllMemories();

    setState(() {
      memories.clear();
      memories.addAll(loadedMemories);
    });
  }

  void addMemory(Memory memory) {
    final id = MemoryDatabase.insertMemory(memory);
    memory.id = id;

    setState(() {
      memories.add(memory);
      memories.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  void deleteMemory(Memory memory) {
    if (memory.id != null) {
      MemoryDatabase.deleteMemory(memory.id!);
    }

    setState(() {
      memories.remove(memory);
    });
  }

  void updateMemory(
    Memory memory,
    String newContent,
    DateTime newDate,
  ) {
    memory.content = newContent;
    memory.date = newDate;

    MemoryDatabase.updateMemory(memory);

    setState(() {
      memories.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  void exportData() {
    try {
      final exportPath = MemoryDatabase.exportDatabase();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('数据已导出到桌面:\n$exportPath'),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败: $e')),
      );
    }
  }

  Future<void> importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) return;

      if (!mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('导入数据'),
          content: const Text('导入将替换当前所有数据，确定继续吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确定导入'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final count = MemoryDatabase.importDatabase(filePath);
      loadMemories();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入成功！共 $count 条记忆')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '记忆漂流瓶',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamilyFallback: const [
          'Microsoft YaHei',
          'SimHei',
          'Arial',
        ],
      ),
      home: HomePage(
        memories: memories,
        onAddMemory: addMemory,
        onDeleteMemory: deleteMemory,
        onUpdateMemory: updateMemory,
        onExport: exportData,
        onImport: importData,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Memory> memories;
  final Function(Memory) onAddMemory;
  final void Function(Memory memory) onDeleteMemory;
  final void Function(Memory memory, String newContent, DateTime newDate)
      onUpdateMemory;
  final VoidCallback onExport;
  final VoidCallback onImport;

  const HomePage({
    super.key,
    required this.memories,
    required this.onAddMemory,
    required this.onDeleteMemory,
    required this.onUpdateMemory,
    required this.onExport,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("记忆漂流瓶"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WriteMemoryPage(
                        onSave: onAddMemory,
                      ),
                    ),
                  );
                },
                child: const Text("写下记忆"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemoryListPage(
                        memories: memories,
                        onDeleteMemory: onDeleteMemory,
                        onUpdateMemory: onUpdateMemory,
                      ),
                    ),
                  );
                },
                child: const Text("查看记忆"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: memories.isEmpty
                    ? null
                    : () {
                        final random = Random();
                        final memory =
                            memories[random.nextInt(memories.length)];

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BottlePage(memory: memory),
                          ),
                        );
                      },
                child: const Text("拾取漂流瓶"),
              ),

              const SizedBox(height: 32),
              const Divider(indent: 40, endIndent: 40),
              const SizedBox(height: 16),
              Text(
                "数据管理",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: onExport,
                icon: const Icon(Icons.upload_outlined, size: 18),
                label: const Text("导出备份"),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text("导入备份"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _contentController.dispose();
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
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}";

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

class MemoryListPage extends StatelessWidget {
  final List<Memory> memories;
  final void Function(Memory memory) onDeleteMemory;
  final void Function(Memory memory, String newContent, DateTime newDate)
      onUpdateMemory;

  const MemoryListPage({
    super.key,
    required this.memories,
    required this.onDeleteMemory,
    required this.onUpdateMemory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("查看记忆"),
      ),
      body: memories.isEmpty
          ? const Center(
              child: Text("还没有任何记忆"),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: memories.length,
              itemBuilder: (context, index) {
                final memory = memories[index];
                final dateText =
                    "${memory.date.year}-${memory.date.month}-${memory.date.day}";

                return Card(
                  child: ListTile(
                    title: Text(
                      memory.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(dateText),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MemoryDetailPage(
                            memory: memory,
                            onDeleteMemory: onDeleteMemory,
                            onUpdateMemory: onUpdateMemory,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class BottlePage extends StatelessWidget {
  final Memory memory;

  const BottlePage({
    super.key,
    required this.memory,
  });

  @override
  Widget build(BuildContext context) {
    final dateText =
        "${memory.date.year}-${memory.date.month}-${memory.date.day}";

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
                  Center(
                    child: Text(
                      dateText,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    memory.content,
                    style: Theme.of(context).textTheme.bodyLarge,
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

class MemoryDetailPage extends StatefulWidget {
  final Memory memory;
  final void Function(Memory memory) onDeleteMemory;
  final void Function(Memory memory, String newContent, DateTime newDate)
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
    final dateText =
        "${widget.memory.date.year}-${widget.memory.date.month}-${widget.memory.date.day}";

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
                              onUpdateMemory: widget.onUpdateMemory,
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
                                  Navigator.pop(context); // 返回上一页
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

class EditMemoryPage extends StatefulWidget {
  final Memory memory;
  final void Function(Memory memory, String newContent, DateTime newDate)
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
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.memory.content,
    );
    _selectedDate = widget.memory.date;
  }

  @override
  void dispose() {
    _contentController.dispose();
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
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}";

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
