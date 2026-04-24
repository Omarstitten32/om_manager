import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:om_manager/models/file_item.dart';
import 'package:om_manager/services/file_service.dart';
import 'package:om_manager/widgets/file_tile.dart';
import 'package:om_manager/widgets/path_bar.dart';
import 'package:om_manager/screens/about_screen.dart';

/// Main home screen for the file manager
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FileService _fileService;
  late String _currentPath;
  List<FileItem> _files = [];
  bool _isLoading = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedPaths = {};
  String? _clipboardPath;
  bool _isClipboardCut = false;

  @override
  void initState() {
    super.initState();
    _fileService = FileService();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _requestPermissions();
    await _navigateToExternalStorage();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.storage.request();

    if (!mounted) return;

    if (status.isDenied) {
      if (mounted) {
        _showErrorDialog(
          'Storage Permission Required',
          'The app needs access to storage to manage files. '
              'Please grant the permission in settings.',
        );
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        _showErrorDialog(
          'Storage Permission Denied',
          'Storage permission is permanently denied. '
              'Please enable it in app settings.',
        );
      }
    }
  }

  Future<void> _navigateToExternalStorage() async {
    try {
      final directory = await getExternalStorageDirectory();
      final path = directory?.path ?? '/storage/emulated/0';
      setState(() {
        _currentPath = path;
      });
      await _loadFiles();
    } catch (e) {
      _showErrorSnackBar('Failed to access storage: $e');
    }
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final files = await _fileService.listDirectory(_currentPath);
      if (mounted) {
        setState(() {
          _files = files;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('$e');
      }
    }
  }

  Future<void> _navigateToDirectory(FileItem item) async {
    if (item.isDirectory) {
      setState(() {
        _currentPath = item.path;
        _selectedPaths.clear();
        _isSelectionMode = false;
      });
      await _loadFiles();
    }
  }

  void _navigateBack() {
    final parentPath = _fileService.getParentPath(_currentPath);
    if (parentPath != _currentPath) {
      setState(() {
        _currentPath = parentPath;
        _selectedPaths.clear();
        _isSelectionMode = false;
      });
      _loadFiles();
    }
  }

  void _toggleSelection(String path) {
    setState(() {
      if (_selectedPaths.contains(path)) {
        _selectedPaths.remove(path);
      } else {
        _selectedPaths.add(path);
      }

      if (_selectedPaths.isEmpty) {
        _isSelectionMode = false;
      } else {
        _isSelectionMode = true;
      }
    });
  }

  Future<void> _createFolder() async {
    String? folderName;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Folder'),
          content: TextField(
            autofocus: true,
            onChanged: (value) => folderName = value,
            decoration: const InputDecoration(
              hintText: 'Folder name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (folderName != null && folderName!.isNotEmpty) {
                  Navigator.pop(context);
                  _performCreateFolder(folderName!);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performCreateFolder(String folderName) async {
    try {
      final newPath = '$_currentPath/$folderName';
      await _fileService.createDirectory(newPath);
      _showSuccessSnackBar('Folder created successfully');
      await _loadFiles();
    } catch (e) {
      _showErrorSnackBar('$e');
    }
  }

  Future<void> _performCopy() async {
    try {
      for (final path in _selectedPaths) {
        final destPath = '$_currentPath/${path.split('/').last}';
        await _fileService.copy(path, destPath);
      }
      _clearSelection();
      _showSuccessSnackBar('Items copied successfully');
      await _loadFiles();
    } catch (e) {
      _showErrorSnackBar('$e');
    }
  }

  void _performCut() {
    if (_selectedPaths.isNotEmpty) {
      _clipboardPath = _selectedPaths.first;
      _isClipboardCut = true;
      _clearSelection();
      _showSuccessSnackBar('Item cut to clipboard');
    }
  }

  Future<void> _performPaste() async {
    if (_clipboardPath == null) return;

    try {
      final destPath =
          '$_currentPath/${_clipboardPath!.split('/').last}';

      if (_isClipboardCut) {
        await _fileService.move(_clipboardPath!, destPath);
      } else {
        await _fileService.copy(_clipboardPath!, destPath);
      }

      _clipboardPath = null;
      _isClipboardCut = false;
      _showSuccessSnackBar('Item pasted successfully');
      await _loadFiles();
    } catch (e) {
      _showErrorSnackBar('$e');
    }
  }

  Future<void> _performDelete() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
              'Are you sure you want to delete ${_selectedPaths.length} item(s)?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _executeDelete();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _executeDelete() async {
    try {
      for (final path in _selectedPaths) {
        await _fileService.delete(path);
      }
      _clearSelection();
      _showSuccessSnackBar('Items deleted successfully');
      await _loadFiles();
    } catch (e) {
      _showErrorSnackBar('$e');
    }
  }

  Future<void> _performShare() async {
    if (_selectedPaths.isEmpty) return;

    try {
      await Share.shareXFiles(
        _selectedPaths
            .where((path) {
              final type = FileSystemEntity.typeSync(path);
              return type == FileSystemEntityType.file;
            })
            .map((path) => XFile(path))
            .toList(),
        text: 'Sharing files from OM Manager',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to share: $e');
    }
  }

  Future<void> _showFileInfo() async {
    if (_selectedPaths.isEmpty) return;

    final path = _selectedPaths.first;
    final file = _files.firstWhere((f) => f.path == path);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('File Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Name:', file.name),
              _infoRow('Path:', file.path),
              _infoRow('Type:', file.isDirectory ? 'Folder' : 'File'),
              if (!file.isDirectory) _infoRow('Size:', file.formattedSize),
              _infoRow('Modified:', _formatDate(file.modified)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _clearSelection() {
    setState(() {
      _selectedPaths.clear();
      _isSelectionMode = false;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              title: Text('${_selectedPaths.length} selected'),
              backgroundColor: Colors.blue.shade600,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _performCopy,
                  tooltip: 'Copy',
                ),
                IconButton(
                  icon: const Icon(Icons.cut),
                  onPressed: _performCut,
                  tooltip: 'Cut',
                ),
                if (_clipboardPath != null)
                  IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: _performPaste,
                    tooltip: 'Paste',
                  ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: _performShare,
                  tooltip: 'Share',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _performDelete,
                  tooltip: 'Delete',
                ),
                IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: _showFileInfo,
                  tooltip: 'Info',
                ),
              ],
            )
          : AppBar(
              title: const Text('OM Manager'),
              leading: _currentPath != '/storage/emulated/0'
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _navigateBack,
                    )
                  : null,
              actions: [
                if (_clipboardPath != null)
                  IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: _performPaste,
                    tooltip: 'Paste',
                  ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  },
                  tooltip: 'About',
                ),
              ],
            ),
      body: Column(
        children: [
          PathBar(
            currentPath: _currentPath,
            onPathTap: (segment) {
              // Navigate to root or specific path segment
              if (segment == '/storage/emulated/0') {
                setState(() {
                  _currentPath = segment;
                  _selectedPaths.clear();
                  _isSelectionMode = false;
                });
                _loadFiles();
              }
            },
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _files.isEmpty
                    ? const Center(child: Text('No files or folders'))
                    : ListView.builder(
                        itemCount: _files.length,
                        itemBuilder: (context, index) {
                          final file = _files[index];
                          final isSelected = _selectedPaths.contains(file.path);

                          return FileTile(
                            fileItem: file,
                            isSelected: isSelected,
                            onTap: () {
                              if (_isSelectionMode) {
                                _toggleSelection(file.path);
                              } else {
                                _navigateToDirectory(file);
                              }
                            },
                            onLongPress: () {
                              _toggleSelection(file.path);
                            },
                            showCheckbox: _isSelectionMode,
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: _createFolder,
              tooltip: 'Create Folder',
              child: const Icon(Icons.add),
            ),
    );
  }
}
