/// Constants used throughout the app
class AppConstants {
  // App name and version
  static const String appName = 'OM Manager';
  static const String appVersion = '1.0.0';

  // Storage paths
  static const String documentsFolder = 'Documents';
  static const String downloadsFolder = 'Downloads';
  static const String picturesFolder = 'Pictures';

  // File type extensions
  static const List<String> imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
  ];
  static const List<String> textExtensions = [
    'txt',
    'md',
    'json',
    'xml',
    'yaml',
    'dart',
    'java',
    'kt',
  ];
  static const List<String> archiveExtensions = ['zip', 'rar', '7z', 'tar'];

  // Sorting options
  static const String sortByName = 'name';
  static const String sortBySize = 'size';
  static const String sortByDate = 'date';

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
}
