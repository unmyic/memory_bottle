import 'package:flutter/material.dart';

import '../models/memory.dart';

class MemoryCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final hasTags = memory.tags.trim().isNotEmpty;

    return Hero(
      tag: 'memory-${memory.id}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memory.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    if (hasTags) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.sell_outlined,
                        size: 15,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          memory.tags,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ] else
                      const Spacer(),

                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}