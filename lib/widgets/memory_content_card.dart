import 'package:flutter/material.dart';

import '../models/memory.dart';
import 'tag_text.dart';

class MemoryContentCard extends StatelessWidget {
  final Memory memory;
  final String dateText;
  final Widget? trailing;

  const MemoryContentCard({
    super.key,
    required this.memory,
    required this.dateText,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  dateText,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
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

            if (trailing != null) ...[
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: trailing,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
