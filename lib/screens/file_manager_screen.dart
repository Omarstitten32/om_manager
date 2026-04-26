import 'package:flutter/material.dart';
import 'package:file_manager/file_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class FileManagerScreen extends StatefulWidget {
  const FileManagerScreen({super.key});

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  late RootProvider _rootProvider;
  late FileSystemProvider _fileSystemProvider;

  @override
  void initState() {
    super.initState();
    _rootProvider = RootProvider();
    _fileSystemProvider = FileSystemProvider(_rootProvider);
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Manager'), elevation: 2),
      body: ChangeNotifierProvider<FileSystemProvider>(
        create: (_) => _fileSystemProvider,
        child: Consumer<FileSystemProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                Expanded(
                  child: FileManager(
                    child: ControlButtons(
                      onBackPressed: () {
                        if (provider.isRootDirectory) {
                          return;
                        }
                        provider.goToParentDirectory();
                      },
                      onHomePressed: () {
                        provider.goToRootDirectory();
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onHomePressed;

  const ControlButtons({
    super.key,
    required this.onBackPressed,
    required this.onHomePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBackPressed,
          ),
          IconButton(icon: const Icon(Icons.home), onPressed: onHomePressed),
          Expanded(
            child: Consumer<FileSystemProvider>(
              builder: (context, provider, _) {
                return Text(
                  provider.breadCrumbs.join(' / '),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
