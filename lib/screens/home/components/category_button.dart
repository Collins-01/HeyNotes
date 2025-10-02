import 'package:flutter/material.dart';
import 'package:hey_notes/core/theme/app_colors.dart';
import 'package:hey_notes/core/utils/ui_helpers.dart';
import 'package:hey_notes/models/category.dart';

class CategoryButton extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final void Function()? onTap;

  const CategoryButton({
    super.key,
    required this.category,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
