import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hey_notes/core/theme/app_colors.dart';
import 'package:hey_notes/core/utils/dialogs.dart';
import 'package:hey_notes/core/utils/ui_helpers.dart';
import 'package:hey_notes/core/utils/utils.dart';
import 'package:hey_notes/widgets/show_svg.dart';
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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete != null ? () => _showDeleteDialog(context) : null,
      child: Container(
        decoration: BoxDecoration(
          color: note.color == null
              ? AppColors.getRandomNoteColor()
              : note.parsedColor,
          borderRadius: BorderRadius.circular(UIHelpers.borderRadiusMd),
          boxShadow: isDarkMode
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(UIHelpers.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Gap(UIHelpers.md),
                  if (note.isPinned)
                    ShowSVG(
                      svgPath: IconAssets.pushPinFilled,
                      height: 20,
                      width: 20,
                      color: isDarkMode ? Colors.white : AppColors.textBlack,
                    ),
                ],
              ),
              const Gap(UIHelpers.md),
              if (note.getPlainText().isNotEmpty) ...[
                Expanded(
                  child: Text(
                    note.getPlainText(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor.withOpacity(0.9),
                    ),
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
