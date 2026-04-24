import 'package:flutter/material.dart';

/// Widget for displaying the current file path with navigation
class PathBar extends StatelessWidget {
  final String currentPath;
  final Function(String) onPathTap;

  const PathBar({
    super.key,
    required this.currentPath,
    required this.onPathTap,
  });

  @override
  Widget build(BuildContext context) {
    final pathSegments = currentPath.split('/').where((p) => p.isNotEmpty).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            InkWell(
              onTap: () => onPathTap('/storage/emulated/0'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  'Storage',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            ...List.generate(pathSegments.length, (index) {
              return Row(
                children: [
                  Text(
                    ' / ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  InkWell(
                    onTap: () => onPathTap(pathSegments[index]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        pathSegments[index],
                        style: TextStyle(
                          color: index == pathSegments.length - 1
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.primary,
                          fontWeight: index == pathSegments.length - 1
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
