import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/memory.dart';
import '../models/attachment.dart';
import '../providers/memory_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/memory_content_card.dart';

import 'memory_detail_page.dart';

class BottlePage extends StatefulWidget {
  final List<Memory> memories;

  const BottlePage({
    super.key,
    required this.memories,
  });

  @override
  State<BottlePage> createState() => _BottlePageState();
}

class _BottlePageState extends State<BottlePage> {
  late Memory currentMemory;
  late List<Memory> remainingMemories;
  List<Attachment>? _attachments;

  @override
  void initState() {
    super.initState();
    remainingMemories = List.from(widget.memories);
    pickRandomMemory();
    _loadAttachments();
  }

  void pickRandomMemory() {
    final random = Random();
    final index = random.nextInt(remainingMemories.length);
    currentMemory = remainingMemories.removeAt(index);
  }

  void _pickNextBottle() {
    if (remainingMemories.isEmpty) return;
    pickRandomMemory();
    _attachments = null;
    setState(() {});
    _loadAttachments();
  }

  void _loadAttachments() async {
    if (currentMemory.id == null) return;
    final attachments =
        await context.read<MemoryProvider>().getAttachments(currentMemory.id!);
    if (mounted) setState(() => _attachments = attachments);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = formatDate(currentMemory.date);
    final daysText = daysAgoText(currentMemory.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text("拾取漂流瓶"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.85, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.waves_outlined,
                        size: 54,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "你拾到了一段过去的记忆",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "它从时间的海面漂到了你面前",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
                child: MemoryContentCard(
                    key: ValueKey(
                      currentMemory.id ??
                          "${currentMemory.content}-${currentMemory.date}",
                    ),
                    memory: currentMemory,
                    dateText: dateText,
                    attachments: _attachments,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        daysText,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MemoryDetailPage(
                        memory: currentMemory,
                      ),
                    ),
                  ).then((deleted) {
                    if (!context.mounted) return;
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
                icon: const Icon(Icons.open_in_new),
                label: const Text("查看这条记忆详情"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(120, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              ElevatedButton.icon(
                onPressed:
                    remainingMemories.isEmpty ? null : _pickNextBottle,
                icon: Icon(
                  remainingMemories.isEmpty
                      ? Icons.check_circle_outline
                      : Icons.shuffle,
                ),
                label: Text(
                  remainingMemories.isEmpty
                      ? "已经没有新的漂流瓶了"
                      : "再拾取一个",
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "本次还剩 ${remainingMemories.length} 个可拾取的漂流瓶",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
