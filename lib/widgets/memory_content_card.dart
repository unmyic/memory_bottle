import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../models/memory.dart';
import '../models/attachment.dart';
import '../pages/image_viewer_page.dart';
import 'tag_text.dart';

class MemoryContentCard extends StatelessWidget {
  final Memory memory;
  final String dateText;
  final Widget? trailing;
  final List<Attachment>? attachments;

  const MemoryContentCard({
    super.key,
    required this.memory,
    required this.dateText,
    this.trailing,
    this.attachments,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(dateText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TagText(tags: memory.tags),
              const SizedBox(height: 20),
              Divider(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.18),
              ),
              const SizedBox(height: 20),
              Text(
                memory.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.75,
                      fontSize: 17,
                    ),
              ),

              // ---- 附件展示 ----
              if (attachments != null && attachments!.isNotEmpty) ...[
                const SizedBox(height: 20),
                _AttachmentsPreview(attachments: attachments!),
              ],

              if (trailing != null) ...[
                const SizedBox(height: 24),
                Align(alignment: Alignment.centerRight, child: trailing),
              ],
            ],
          ),
        ),
    );
  }
}

class _AttachmentsPreview extends StatelessWidget {
  final List<Attachment> attachments;
  const _AttachmentsPreview({required this.attachments});

  @override
  Widget build(BuildContext context) {
    final images = attachments.where((a) => a.isImage).toList();
    final docs = attachments.where((a) => !a.isImage).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: images.map((a) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImageViewerPage(
                        imagePath: a.filePath,
                        title: a.fileName,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(a.filePath),
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, e, s) => Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 24),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        if (docs.isNotEmpty) ...[
          if (images.isNotEmpty) const SizedBox(height: 8),
          ...docs.map((a) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => OpenFilex.open(a.filePath),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 8),
                    child: Row(
                      children: [
                        Icon(Icons.description,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(a.fileName,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Icon(Icons.open_in_new,
                            size: 16,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ],
    );
  }
}
