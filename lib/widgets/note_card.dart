import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hey_notes/core/utils/ui_helpers.dart';
import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onDelete,
  });

  Future<void> _showDeleteDialog(BuildContext context) async {
    final isConfirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => Platform.isIOS || Platform.isMacOS
              ? CupertinoAlertDialog(
                  title: const Text('Delete Note'),
                  content: const Text(
                    'Are you sure you want to delete this note?',
                  ),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    CupertinoDialogAction(
                      onPressed: () => Navigator.of(context).pop(true),
                      isDestructiveAction: true,
                      child: const Text('Delete'),
                    ),
                  ],
                )
              : AlertDialog(
                  title: const Text('Delete Note'),
                  content: const Text(
                    'Are you sure you want to delete this note?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text('DELETE'),
                    ),
                  ],
                ),
        ) ??
        false;

    if (isConfirmed && context.mounted && onDelete != null) {
      onDelete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete != null ? () => _showDeleteDialog(context) : null,
      child: Container(
        decoration: BoxDecoration(
          color: note.parsedColor,
          borderRadius: BorderRadius.circular(UIHelpers.borderRadiusMd),
        ),
        child: Padding(
          padding: const EdgeInsets.all(UIHelpers.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.title.isNotEmpty) ...[
                Text(
                  note.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],
              if (note.content.isNotEmpty) ...[
                Expanded(
                  child: Text(
                    note.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
