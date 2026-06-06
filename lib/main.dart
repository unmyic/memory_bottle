import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MemoryBottleApp());
}

class Memory {
  int? id;
  String content;
  DateTime date;
  String tags;

  Memory({
    this.id,
    required this.content,
    required this.date,
    this.tags = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'date': date.toIso8601String(),
      'tags': tags,
    };
  }

  static Memory fromMap(Map<String, dynamic> map) {
    return Memory(
      id: map['id'],
      content: map['content'],
      date: DateTime.parse(map['date']),
      tags: map['tags'] ?? "",
    );
  }
}

class MemoryDatabase {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'memory_bottle.db');

    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE memories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            date TEXT NOT NULL,
            tags TEXT NOT NULL DEFAULT ''
          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE memories ADD COLUMN tags TEXT NOT NULL DEFAULT ''",
          );
        }
      },
    );

    return _database!;
  }

    
  static Future<int> insertMemory(Memory memory) async {
    final db = await getDatabase();
    return await db.insert('memories', memory.toMap());
  }

  static Future<List<Memory>> getAllMemories() async {
    final db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(
      'memories',
      orderBy: 'date DESC',
    );

    return maps.map((map) => Memory.fromMap(map)).toList();
  }

  static Future<int> updateMemory(Memory memory) async {
    final db = await getDatabase();

    return await db.update(
      'memories',
      memory.toMap(),
      where: 'id = ?',
      whereArgs: [memory.id],
    );
  }

  static Future<int> deleteMemory(int id) async {
    final db = await getDatabase();

    return await db.delete(
      'memories',
      where: 'id = ?',
     whereArgs: [id],
    );
  }
}

String formatDate(DateTime date) {
  final year = date.year;
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return "$year年$month月$day日";
}

String daysAgoText(DateTime date) {
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final targetDay = DateTime(date.year, date.month, date.day);

  final days = today.difference(targetDay).inDays;

  if (days == 0) {
    return "这是今天的你";
  } else if (days > 0) {
    return "这是 $days 天前的你";
  } else {
    return "这是 ${-days} 天后的你";
  }
}

String seasonText(DateTime date) {
  final month = date.month;

  if (month >= 3 && month <= 5) {
    return "春季";
  } else if (month >= 6 && month <= 8) {
    return "夏季";
  } else if (month >= 9 && month <= 11) {
    return "秋季";
  } else {
    return "冬季";
  }
}

String monthGroupTitle(DateTime date) {
  final year = date.year;
  final month = date.month.toString().padLeft(2, '0');
  final season = seasonText(date);

  return "$year年 · $season · $month月";
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

  Future<void> loadMemories() async {
    final loadedMemories = await MemoryDatabase.getAllMemories();

    setState(() {
      memories.clear();
      memories.addAll(loadedMemories);
    });
  }
  
  Future<void> addMemory(Memory memory) async {
    final id = await MemoryDatabase.insertMemory(memory);
    memory.id = id;

    setState(() {
      memories.add(memory);
      memories.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> deleteMemory(Memory memory) async {
    if (memory.id != null) {
      await MemoryDatabase.deleteMemory(memory.id!);
    }

    setState(() {
      memories.remove(memory);
    });
  }

  Future<void> updateMemory(
    Memory memory,
    String newContent,
    DateTime newDate,
    String newTags,
  ) async {
    memory.content = newContent;
    memory.date = newDate;
    memory.tags = newTags;

    await MemoryDatabase.updateMemory(memory);

    setState(() {
      memories.sort((a, b) => b.date.compareTo(a.date));
    });
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
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Memory> memories;
  final Function(Memory) onAddMemory;
  final void Function(Memory memory) onDeleteMemory;
  final void Function(
    Memory memory,
    String newContent,
    DateTime newDate,
    String newTags,
  ) 
    onUpdateMemory;

  const HomePage({
    super.key,
    required this.memories,
    required this.onAddMemory,
    required this.onDeleteMemory,
    required this.onUpdateMemory,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount = memories.length;
    final earliestMemory = memories.isEmpty ? null : memories.last;
    final latestMemory = memories.isEmpty ? null : memories.first;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final bottleCount = memories.where((memory) {
      final memoryDay = DateTime(
        memory.date.year,
        memory.date.month,
        memory.date.day,
      );

      return memoryDay.isBefore(today);
    }).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("记忆漂流瓶"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "已保存 $totalCount 条记忆",
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 6),

            Text(
              "可拾取 $bottleCount 个漂流瓶",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            if (earliestMemory != null) ...[
              const SizedBox(height: 6),
              Text(
                "最早记忆：${formatDate(earliestMemory.date)}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            if (latestMemory != null) ...[
              const SizedBox(height: 6),
              Text(
                "最近记忆：${formatDate(latestMemory.date)}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            const SizedBox(height: 30),

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
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);

                      final pastMemories = memories.where((memory) {
                        final memoryDay = DateTime(
                          memory.date.year,
                          memory.date.month,
                          memory.date.day,
                        );

                        return memoryDay.isBefore(today);
                      }).toList();

                      if (pastMemories.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("还没有可以拾取的过去记忆"),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BottlePage(
                            memories: pastMemories,
                            onDeleteMemory: onDeleteMemory,
                            onUpdateMemory: onUpdateMemory,
                          ),
                        ),
                      );
                    },
              child: const Text("拾取漂流瓶"),
            ),
          ],
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

class MemoryListPage extends StatefulWidget {
  final List<Memory> memories;
  final void Function(Memory memory) onDeleteMemory;
  final void Function(
    Memory memory,
    String newContent, 
    DateTime newDate,
    String newTags,
  ) 
    onUpdateMemory;

  const MemoryListPage({
    super.key,
    required this.memories,
    required this.onDeleteMemory,
    required this.onUpdateMemory,
  });

  @override
  State<MemoryListPage> createState() => _MemoryListPageState();
}

class _MemoryListPageState extends State<MemoryListPage> {
  String searchText = "";
  String filterMode = "全部";
  String selectedTag = "";

  bool matchFilter(Memory memory) {
    if (selectedTag.isNotEmpty) {
      final tagList = memory.tags
          .split(",")
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      if (!tagList.contains(selectedTag)) {
        return false;
      }
    }

    final now = DateTime.now();
    final memoryDate = memory.date;

    if (filterMode == "全部") {
      return true;
    }

    if (filterMode == "今天") {
      return memoryDate.year == now.year &&
          memoryDate.month == now.month &&
          memoryDate.day == now.day;
    }

    if (filterMode == "本月") {
      return memoryDate.year == now.year &&
          memoryDate.month == now.month;
    }

    if (filterMode == "今年") {
      return memoryDate.year == now.year;
    }

    if (filterMode == "本季") {
      return memoryDate.year == now.year &&
          seasonText(memoryDate) == seasonText(now);
    }

    return true;
  }

  String emptyMessage() {
    final keyword = searchText.trim();

    if (widget.memories.isEmpty) {
      return "还没有任何记忆";
    }

    if (keyword.isNotEmpty) {
      return "没有找到包含“$keyword”的记忆";
    }

    if (filterMode == "今天") {
      return "今天还没有记忆";
    }

    if (filterMode == "本月") {
      return "本月还没有记忆";
    }

    if (filterMode == "本季") {
      return "本季还没有记忆";
    }

    if (filterMode == "今年") {
      return "今年还没有记忆";
    }

    return "没有找到相关记忆";
  }

  @override
  Widget build(BuildContext context) {
    final keyword = searchText.trim();

    final allTags = widget.memories
      .expand((memory) => memory.tags.split(","))
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toSet()
      .toList();

    final filteredMemories = widget.memories.where((memory) {
      if (!matchFilter(memory)) {
        return false;
      }
      if (keyword.isEmpty) {
        return true;
      }

      final dateText = formatDate(memory.date);
      final groupText = monthGroupTitle(memory.date);
      final season = seasonText(memory.date);
      final year = memory.date.year.toString();
      final month = "${memory.date.month.toString().padLeft(2, '0')}月";

      final isTooBroadTimeKeyword =
          keyword == "年" || keyword == "月" || keyword == "季";

      final matchesContent = memory.content.contains(keyword);
      final matchesTags = memory.tags.contains(keyword);

      final matchesTime = !isTooBroadTimeKeyword &&
          (dateText.contains(keyword) ||
              groupText.contains(keyword) ||
              season.contains(keyword) ||
              year.contains(keyword) ||
              month.contains(keyword));

      return matchesContent || matchesTags || matchesTime;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("查看记忆"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "搜索记忆",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                "全部",
                "今天",
                "本月",
                "本季",
                "今年",
              ].map((mode) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(mode),
                    selected: filterMode == mode,
                    onSelected: (_) {
                      setState(() {
                        filterMode = mode;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          if (allTags.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text("全部标签"),
                      selected: selectedTag.isEmpty,
                      onSelected: (_) {
                        setState(() {
                          selectedTag = "";
                        });
                      },
                    ),
                  ),
                  ...allTags.map((tag) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(tag),
                        selected: selectedTag == tag,
                        onSelected: (_) {
                          setState(() {
                            selectedTag = tag;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

          if (allTags.isNotEmpty)
            const SizedBox(height: 8),

          Expanded(
            child: filteredMemories.isEmpty
              ? Center(
                  child: Text(emptyMessage()),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredMemories.length,
                  itemBuilder: (context, index) {
                    final memory = filteredMemories[index];
                    final dateText = formatDate(memory.date);

                    String? groupTitle;

                    if (index == 0) {
                      groupTitle = monthGroupTitle(memory.date);
                    } else {
                      final previousMemory = filteredMemories[index - 1];
                      final currentGroup = monthGroupTitle(memory.date);
                      final previousGroup = monthGroupTitle(previousMemory.date);

                      if (currentGroup != previousGroup) {
                        groupTitle = currentGroup;
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (groupTitle != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              top: 16,
                              bottom: 8,
                            ),
                            child: Text(
                              groupTitle,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),

                        Card(
                          child: ListTile(
                            title: Text(
                              memory.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              memory.tags.isEmpty
                                ?dateText
                                :"$dateText · ${memory.tags}"),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MemoryDetailPage(
                                    memory: memory,
                                    onDeleteMemory: widget.onDeleteMemory,
                                    onUpdateMemory: widget.onUpdateMemory,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

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

                  if (widget.memory.tags.isNotEmpty)
                    Text(
                      "标签：${widget.memory.tags}",
                      style: Theme.of(context).textTheme.bodyMedium,
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