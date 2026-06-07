import 'package:flutter/material.dart';

class TagText extends StatelessWidget {
  final String tags;
  final String prefix;

  const TagText({
    super.key,
    required this.tags,
    this.prefix = '标签：',
  });

  @override
  Widget build(BuildContext context) {
    if (tags.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      '$prefix$tags',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}