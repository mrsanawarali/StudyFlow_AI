import 'dart:typed_data';
import 'package:flutter/material.dart';

class FullScreenImageViewer extends StatelessWidget {
  final Uint8List imageBytes;
  final String title;

  const FullScreenImageViewer({
    super.key,
    required this.imageBytes,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF1B2660),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          child: Image.memory(imageBytes),
        ),
      ),
    );
  }
}
