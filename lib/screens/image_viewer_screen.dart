import 'package:flutter/material.dart';

/// Screen for viewing images
class ImageViewerScreen extends StatefulWidget {
  final String imagePath;

  const ImageViewerScreen({super.key, required this.imagePath});

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Viewer')),
      body: Center(child: Text('Image viewer for: ${widget.imagePath}')),
    );
  }
}
