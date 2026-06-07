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
    return Card(
      child: ListTile(
        title: Text(
          memory.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          memory.tags.isEmpty ? dateText : "$dateText · ${memory.tags}",
        ),
        onTap: onTap,
      ),
    );
  }
}