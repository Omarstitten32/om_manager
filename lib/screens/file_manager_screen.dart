import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class FileManagerScreen extends StatefulWidget {
  const FileManagerScreen({super.key});

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  List<FileSystemEntity> _files = [];
  String _currentPath = '/storage/emulated/0';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoad();
  }

  Future<void> _requestPermissionAndLoad() async {
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      setState(() {
        _error = 'Storage permission is required. Please grant it in settings.';
        _isLoading = false;
      });
      return;
    }
    await _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    try {
      final dir = Directory(_currentPath);
      final List<FileSystemEntity> entities = await dir.list().toList();
      entities.sort((a, b) {
        if (a is Directory && b is File) return -1;
        if (a is File && b is Directory) return 1;
        return a.path.compareTo(b.path);
      });
      setState(() {
        _files = entities;
        _error = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load directory: $e';
        _isLoading = false;
      });
    }
  }

  void _openDirectory(Directory dir) {
    setState(() {
      _currentPath = dir.path;
    });
    _loadFiles();
  }

  void _goBack() {
    if (_currentPath == '/storage/emulated/0') return;
    final parent = Directory(_currentPath).parent;
    setState(() {
      _currentPath = parent.path;
    });
    _loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPath),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _files.isEmpty
                  ? const Center(child: Text('This folder is empty'))
                  : ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (ctx, index) {
                        final entity = _files[index];
                        final isDir = entity is Directory;
                        final name = entity.path.split('/').last;
                        final icon = isDir ? Icons.folder : Icons.insert_drive_file;
                        return ListTile(
                          leading: Icon(icon, color: isDir ? Colors.amber : Colors.blue),
                          title: Text(name),
                          onTap: () {
                            if (isDir) _openDirectory(entity as Directory);
                          },
                        );
                      },
                    ),
    );
  }
}
