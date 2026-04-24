import 'package:flutter/material.dart';

/// Dialog for sorting files
class SortDialog extends StatefulWidget {
  final String currentSortBy;
  final bool sortAscending;
  final Function(String, bool) onSortChanged;

  const SortDialog({
    super.key,
    required this.currentSortBy,
    required this.sortAscending,
    required this.onSortChanged,
  });

  @override
  State<SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<SortDialog> {
  late String _sortBy;
  late bool _ascending;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.currentSortBy;
    _ascending = widget.sortAscending;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sort By'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile(
            title: const Text('Name'),
            value: 'name',
            groupValue: _sortBy,
            onChanged: (value) => setState(() => _sortBy = value!),
          ),
          RadioListTile(
            title: const Text('Size'),
            value: 'size',
            groupValue: _sortBy,
            onChanged: (value) => setState(() => _sortBy = value!),
          ),
          RadioListTile(
            title: const Text('Date'),
            value: 'date',
            groupValue: _sortBy,
            onChanged: (value) => setState(() => _sortBy = value!),
          ),
          const Divider(),
          CheckboxListTile(
            title: const Text('Ascending'),
            value: _ascending,
            onChanged: (value) => setState(() => _ascending = value!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSortChanged(_sortBy, _ascending);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
