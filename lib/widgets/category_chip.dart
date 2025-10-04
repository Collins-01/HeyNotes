import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryChip extends ConsumerWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color? backgroundColor;
  final Color? textColor;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected ? theme.colorScheme.onPrimary : textColor?.withValues(alpha: 0.8),
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        backgroundColor: backgroundColor?.withValues(alpha: 0.1) ?? theme.colorScheme.surfaceContainerHighest,
        selectedColor: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        labelPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
    );
  }
}
