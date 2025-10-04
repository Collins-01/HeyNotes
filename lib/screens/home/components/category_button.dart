
import 'package:flutter/material.dart';
import 'package:hey_notes/core/theme/app_colors.dart';
import 'package:hey_notes/core/utils/dialogs.dart';
import 'package:hey_notes/core/utils/ui_helpers.dart';
import 'package:hey_notes/models/category.dart';

class CategoryButton extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final void Function()? onTap;
  final VoidCallback? onDelete;

  const CategoryButton({
    super.key,
    required this.category,
    required this.isSelected,
    this.onTap,
    this.onDelete,
  });
  Future<void> _showDeleteCategoryDialog(
    BuildContext context,
    Category category,
  ) async {
    final isConfirmed = await AppDialogs.showDeleteConfirmation(
      context: context,
      itemName: category.name,
    );

    if (isConfirmed && onDelete != null) {
      onDelete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete != null
          ? () => _showDeleteCategoryDialog(context, category)
          : null,
      child: Padding(
        padding: const EdgeInsets.only(right: UIHelpers.md),
        child: AnimatedContainer(
          duration: UIHelpers.slowDuration,
          curve: Curves.linear,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.black : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: !isSelected
                  ? AppColors.black.withValues(alpha: .2)
                  : AppColors.black,
            ),
          ),
          padding: const EdgeInsets.only(
            left: UIHelpers.md,
            right: UIHelpers.md,
            top: UIHelpers.xs,
            bottom: UIHelpers.xs,
          ),
          child: Text(
            category.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isSelected ? AppColors.white : AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
