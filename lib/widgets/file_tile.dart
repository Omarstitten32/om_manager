import 'package:flutter/material.dart';
import 'package:om_manager/models/file_item.dart';

/// Widget for displaying a single file or folder in a list
class FileTile extends StatelessWidget {
  final FileItem fileItem;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool showCheckbox;

  const FileTile({
    super.key,
    required this.fileItem,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.showCheckbox = false,
  });

  IconData _getFileIcon() {
    if (fileItem.isDirectory) {
      return Icons.folder;
    } else if (fileItem.isImage) {
      return Icons.image;
    } else if (fileItem.isText) {
      return Icons.text_fields;
    } else if (fileItem.isZip) {
      return Icons.archive;
    } else {
      return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isSelected ? Colors.blue.shade50 : null,
      child: ListTile(
        leading: showCheckbox
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => onTap?.call(),
              )
            : Icon(_getFileIcon()),
        title: Text(fileItem.name),
        subtitle: fileItem.isDirectory
            ? null
            : Text(
                fileItem.formattedSize,
                style: Theme.of(context).textTheme.bodySmall,
              ),
        trailing: isSelected && !showCheckbox
            ? const Icon(Icons.check_circle, color: Colors.blue)
            : null,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
