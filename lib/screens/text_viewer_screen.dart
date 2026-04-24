import 'package:flutter/material.dart';

/// Screen for viewing text files
class TextViewerScreen extends StatefulWidget {
  final String filePath;

  const TextViewerScreen({super.key, required this.filePath});

  @override
  State<TextViewerScreen> createState() => _TextViewerScreenState();
}

class _TextViewerScreenState extends State<TextViewerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Viewer')),
      body: Center(child: Text('Text viewer for: ${widget.filePath}')),
    );
  }
}
