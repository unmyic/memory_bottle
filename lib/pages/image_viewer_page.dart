import 'dart:io';

import 'package:flutter/material.dart';

class ImageViewerPage extends StatelessWidget {
  final String imagePath;
  final String? title;

  const ImageViewerPage({
    super.key,
    required this.imagePath,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title ?? '查看图片',
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            errorBuilder: (_, e, s) => const Icon(
              Icons.broken_image,
              color: Colors.white54,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}
