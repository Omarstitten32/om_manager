/// Model class representing a file or folder in the file system
class FileItem {
  /// The name of the file or folder
  final String name;

  /// The full path to the file or folder
  final String path;

  /// Whether this item is a directory
  final bool isDirectory;

  /// File size in bytes
  final int size;

  /// Last modified time
  final DateTime modified;

  /// File MIME type
  final String? mimeType;

  FileItem({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    required this.modified,
    this.mimeType,
  });

  /// Get human-readable file size
  String get formattedSize {
    if (isDirectory) return '';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(2)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Check if file is an image
  bool get isImage {
    if (isDirectory) return false;
    final ext = name.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  /// Check if file is a text file
  bool get isText {
    if (isDirectory) return false;
    final ext = name.toLowerCase().split('.').last;
    return [
      'txt',
      'md',
      'json',
      'xml',
      'yaml',
      'dart',
      'java',
      'kt',
    ].contains(ext);
  }

  /// Check if file is a zip archive
  bool get isZip {
    if (isDirectory) return false;
    final ext = name.toLowerCase().split('.').last;
    return ext == 'zip';
  }
}
