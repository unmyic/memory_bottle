import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/memory.dart';
import '../providers/memory_provider.dart';

class MemoryCard extends StatefulWidget {
  final Memory memory;
  final String dateText;
  final VoidCallback onTap;

  const MemoryCard({
    super.key,
    required this.memory,
    required this.dateText,
    required this.onTap,
  });

  @override
  State<MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<MemoryCard> {
  String? _thumbnailPath;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  void _loadThumbnail() async {
    if (widget.memory.id == null) return;
    final attachments =
        await context.read<MemoryProvider>().getAttachments(widget.memory.id!);
    final firstImage =
        attachments.where((a) => a.isImage).firstOrNull;
    if (mounted && firstImage != null) {
      setState(() => _thumbnailPath = firstImage.filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTags = widget.memory.tags.trim().isNotEmpty;
    final hasThumbnail = _thumbnailPath != null &&
        File(_thumbnailPath!).existsSync();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 缩略图
              if (hasThumbnail)
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_thumbnailPath!),
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, s) => const SizedBox.shrink(),
                    ),
                  ),
                ),

              // 文本内容
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.memory.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                            Icons.calendar_today_outlined,
                            size: 15,
                            color: Theme.of(context)
                                .colorScheme
                                .primary),
                        const SizedBox(width: 6),
                        Text(widget.dateText,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall),
                        if (hasTags) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.sell_outlined,
                              size: 15,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(widget.memory.tags,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall),
                          ),
                        ] else
                          const Spacer(),
                        Icon(Icons.chevron_right,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
