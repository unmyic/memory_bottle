import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/memory_provider.dart';
import '../models/memory.dart';
import '../utils/date_utils.dart';
import '../widgets/memory_card.dart';
import '../widgets/empty_state.dart';

import 'memory_detail_page.dart';

class MemoryListPage extends StatefulWidget {
  const MemoryListPage({super.key});

  @override
  State<MemoryListPage> createState() => _MemoryListPageState();
}

class _MemoryListPageState extends State<MemoryListPage> {
  String searchText = "";
  String filterMode = "全部";
  String selectedTag = "";
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  bool matchFilter(Memory memory) {
    if (selectedTag.isNotEmpty) {
      final tagList = memory.tags
          .split(",")
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      if (!tagList.contains(selectedTag)) return false;
    }

    final now = DateTime.now();
    final memoryDate = memory.date;

    if (filterMode == "全部") return true;
    if (filterMode == "今天") {
      return memoryDate.year == now.year &&
          memoryDate.month == now.month &&
          memoryDate.day == now.day;
    }
    if (filterMode == "本月") {
      return memoryDate.year == now.year && memoryDate.month == now.month;
    }
    if (filterMode == "今年") return memoryDate.year == now.year;
    if (filterMode == "本季") {
      return memoryDate.year == now.year &&
          seasonText(memoryDate) == seasonText(now);
    }
    return true;
  }

  String emptyMessage() {
    final keyword = searchText.trim();
    final provider = context.read<MemoryProvider>();

    if (provider.memories.isEmpty) return "还没有任何记忆";
    if (keyword.isNotEmpty) return "没有找到包含「$keyword」的记忆";
    if (filterMode == "今天") return "今天还没有记忆";
    if (filterMode == "本月") return "本月还没有记忆";
    if (filterMode == "本季") return "本季还没有记忆";
    if (filterMode == "今年") return "今年还没有记忆";
    return "没有找到相关记忆";
  }

  List<Memory> _filteredMemories(MemoryProvider provider) {
    final keyword = searchText.trim();
    final memories = provider.memories;

    return memories.where((memory) {
      if (!matchFilter(memory)) return false;
      if (keyword.isEmpty) return true;

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
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemoryProvider>();
    final allTags = provider.allTags;
    final filteredMemories = _filteredMemories(provider);

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
                _debounceTimer?.cancel();
                _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                  setState(() {
                    searchText = value;
                  });
                });
              },
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                "全部", "今天", "本月", "本季", "今年",
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

          if (allTags.isNotEmpty) const SizedBox(height: 8),

          Expanded(
            child: filteredMemories.isEmpty
                ? EmptyState(
                    icon: Icons.inbox_outlined,
                    message: emptyMessage(),
                  )
                : RefreshIndicator(
                    onRefresh: provider.loadMemories,
                    child: ListView.builder(
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
                          final previousGroup =
                              monthGroupTitle(previousMemory.date);
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
                                  left: 8, top: 16, bottom: 8,
                                ),
                                child: Text(
                                  groupTitle,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            MemoryCard(
                              memory: memory,
                              dateText: dateText,
                              onTap: () {
                                Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MemoryDetailPage(
                                      memory: memory,
                                    ),
                                  ),
                                ).then((deleted) {
                                  if (!context.mounted) return;
                                  if (deleted == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('记忆已删除')),
                                    );
                                  }
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
