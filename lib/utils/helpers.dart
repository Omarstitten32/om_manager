/// Helper functions for common operations
class Helpers {
  /// Get file extension from filename
  static String getFileExtension(String filename) {
    final parts = filename.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }

  /// Get filename without extension
  static String getFileNameWithoutExtension(String filename) {
    final lastDotIndex = filename.lastIndexOf('.');
    if (lastDotIndex > 0) {
      return filename.substring(0, lastDotIndex);
    }
    return filename;
  }

  /// Check if path is root path
  static bool isRootPath(String path) {
    return path == '/' || path.isEmpty;
  }

  /// Get parent directory path
  static String getParentPath(String path) {
    if (isRootPath(path)) return path;
    final lastSlashIndex = path.lastIndexOf('/');
    if (lastSlashIndex <= 0) return '/';
    return path.substring(0, lastSlashIndex);
  }

  /// Get directory name from path
  static String getDirectoryName(String path) {
    if (isRootPath(path)) return '/';
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.last : '/';
  }

  /// Format file size to human-readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Convert date to readable format
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
