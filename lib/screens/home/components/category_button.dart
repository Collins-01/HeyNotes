import 'package:flutter/material.dart';
import 'package:hey_notes/core/theme/app_colors.dart';
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.black : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.black : AppColors.black,
          ),
        ),
        child: Text(
          category.name,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.black,
          ),
        ),
      ),
    );
  }
}
