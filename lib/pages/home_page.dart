import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/memory_provider.dart';
import '../services/cloud_sync_service.dart';
import '../widgets/settings_sheet.dart';
import '../utils/date_utils.dart';

import 'write_memory_page.dart';
import 'memory_list_page.dart';
import 'bottle_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 回到前台时自动从云端拉取
      final provider = context.read<MemoryProvider>();
      if (provider.cloudAvailable) {
        provider.pullFromCloud().catchError((_) => 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemoryProvider>();
    final memories = provider.memories;
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
        actions: [
          // 云同步状态图标
          if (provider.cloudAvailable)
            _SyncIcon(isSyncing: provider.isSyncing),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: '导出文件',
            onPressed: () => _exportMemories(context),
          ),
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: '导入文件',
            onPressed: () => _importMemories(context),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: '设置',
            onPressed: () => showSettingsSheet(context),
          ),
        ],
        bottom: CloudSyncService().isInitialized && CloudSyncService().isLoggedIn
            ? PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: GestureDetector(
                  onTap: () => _showAccountMenu(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 8),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.account_circle, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          CloudSyncService().userEmail ?? '',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 16),
                      ],
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            Icon(
              Icons.sailing,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 8),

            Text(
              "如果连你也忘了",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 30),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "记忆统计",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      "已保存 $totalCount 条记忆",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "可拾取 $bottleCount 个漂流瓶",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),

                    if (earliestMemory != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "最早记忆：${formatDate(earliestMemory.date)}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),

                    if (latestMemory != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "最近记忆：${formatDate(latestMemory.date)}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WriteMemoryPage(),
                  ),
                );
              },
              icon: const Icon(Icons.edit_note),
              label: const Text("写下记忆"),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MemoryListPage(),
                  ),
                );
              },
              icon: const Icon(Icons.library_books_outlined),
              label: const Text("查看记忆"),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
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
                          builder: (_) => BottlePage(
                            memories: pastMemories,
                          ),
                        ),
                      );
                    },
              icon: const Icon(Icons.waves_outlined),
              label: const Text("拾取漂流瓶"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAccountMenu(BuildContext context) {
    final sync = CloudSyncService();
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
              const Icon(Icons.account_circle, size: 48),
              const SizedBox(height: 8),
              Text(sync.userEmail ?? '',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await sync.signOut();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('退出登录'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportMemories(BuildContext context) async {
    final provider = context.read<MemoryProvider>();
    if (provider.memories.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('还没有记忆可以导出')),
        );
      }
      return;
    }

    try {
      final filePath = await provider.exportToFile();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已导出 ${provider.memories.length} 条记忆'),
            action: SnackBarAction(
              label: '查看路径',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(filePath), duration: const Duration(seconds: 5)),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败：$e')),
        );
      }
    }
  }

  Future<void> _importMemories(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.first.path;
      if (filePath == null) return;

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正在导入...'), duration: Duration(seconds: 1)),
      );

      final provider = context.read<MemoryProvider>();
      final count = await provider.importFromFile(filePath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功导入 $count 条新记忆')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败：$e')),
        );
      }
    }
  }
}

/// 云同步状态图标
class _SyncIcon extends StatelessWidget {
  final bool isSyncing;
  const _SyncIcon({required this.isSyncing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: isSyncing
          ? const Tooltip(
              message: '正在同步...',
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : Tooltip(
              message: '自动同步中',
              child: Icon(
                Icons.cloud_done_outlined,
                size: 22,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
    );
  }
}
