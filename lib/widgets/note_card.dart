import 'package:flutter/material.dart';
import 'package:hey_notes/core/utils/dialogs.dart';
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
    final isConfirmed = await AppDialogs.showDeleteConfirmation(
      context: context,
      itemName: note.title,
    );

    if (isConfirmed && onDelete != null) {
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
                    overflow: TextOverflow.clip,
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
