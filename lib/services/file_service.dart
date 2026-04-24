import 'dart:io';
import 'package:om_manager/models/file_item.dart';

/// Service for handling file operations
class FileService {
  /// List files and folders in a directory
  Future<List<FileItem>> listDirectory(String path) async {
    try {
      final directory = Directory(path);
      
      if (!await directory.exists()) {
        throw 'Directory does not exist';
      }

      final entities = await directory.list().toList();
      final files = <FileItem>[];

      for (var entity in entities) {
        try {
          final stat = await entity.stat();
          final isDir = entity is Directory;
          
          files.add(
            FileItem(
              name: entity.path.split('/').last,
              path: entity.path,
              isDirectory: isDir,
              size: stat.size,
              modified: stat.modified,
              mimeType: isDir ? null : _getMimeType(entity.path),
            ),
          );
        } catch (e) {
          // Skip items we can't read
          continue;
        }
      }

      // Sort: directories first, then alphabetically
      files.sort((a, b) {
        if (a.isDirectory != b.isDirectory) {
          return a.isDirectory ? -1 : 1;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return files;
    } catch (e) {
      throw 'Failed to list directory: $e';
    }
  }

  /// Create a new directory
  Future<void> createDirectory(String path) async {
    try {
      final directory = Directory(path);
      await directory.create(recursive: true);
    } catch (e) {
      throw 'Failed to create directory: $e';
    }
  }

  /// Delete a file or directory
  Future<void> delete(String path) async {
    try {
      final entity = FileSystemEntity.typeSync(path) == FileSystemEntityType.directoryectoryectory
          ? Directory(path)
          : File(path);

      if (entity is Directory) {
        await entity.delete(recursive: true);
      } else {
        await entity.delete();
      }
    } catch (e) {
      throw 'Failed to delete: $e';
    }
  }

  /// Copy a file or directory
  Future<void> copy(String sourcePath, String destPath) async {
    try {
      final sourceType =
          FileSystemEntity.typeSync(sourcePath);

      if (sourceType == FileSystemEntityType.directoryectoryectory) {
        await _copyDirectory(Directory(sourcePath), Directory(destPath));
      } else {
        final sourceFile = File(sourcePath);
        await sourceFile.copy(destPath);
      }
    } catch (e) {
      throw 'Failed to copy: $e';
    }
  }

  /// Move a file or directory
  Future<void> move(String sourcePath, String destPath) async {
    try {
      final entity = FileSystemEntity.typeSync(sourcePath) ==
              FileSystemEntityType.directoryectoryectory
          ? Directory(sourcePath)
          : File(sourcePath);

      await entity.rename(destPath);
    } catch (e) {
      throw 'Failed to move: $e';
    }
  }

  /// Rename a file or directory
  Future<void> rename(String path, String newName) async {
    try {
      final entity = FileSystemEntity.typeSync(path) == FileSystemEntityType.directoryectoryectory
          ? Directory(path)
          : File(path);

      final parentPath = path.substring(0, path.lastIndexOf('/'));
      final newPath = '$parentPath/$newName';
      await entity.rename(newPath);
    } catch (e) {
      throw 'Failed to rename: $e';
    }
  }

  /// Get parent directory path
  String getParentPath(String path) {
    if (path == '/' || !path.contains('/')) {
      return path;
    }
    return path.substring(0, path.lastIndexOf('/'));
  }

  /// Get file extension
  String getFileExtension(String filename) {
    final parts = filename.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }

  /// Get MIME type based on file extension
  String _getMimeType(String filePath) {
    final ext = getFileExtension(filePath).toLowerCase();
    
    const mimeTypes = {
      'txt': 'text/plain',
      'md': 'text/markdown',
      'json': 'application/json',
      'xml': 'application/xml',
      'pdf': 'application/pdf',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'zip': 'application/zip',
    };

    return mimeTypes[ext] ?? 'application/octet-stream';
  }

  /// Helper method to copy a directory recursively
  Future<void> _copyDirectory(Directory source, Directory destination) async {
    if (!await destination.exists()) {
      await destination.create(recursive: true);
    }

    source.listSync().forEach((entity) {
      final name = entity.path.split('/').last;
      final destEntity = '${destination.path}/$name';

      if (entity is File) {
        entity.copySync(destEntity);
      } else if (entity is Directory) {
        _copyDirectory(entity, Directory(destEntity));
      }
    });
  }
}
