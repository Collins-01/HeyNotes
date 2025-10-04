import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hey_notes/core/theme/app_colors.dart';
import 'package:hey_notes/core/utils/ui_helpers.dart';
import 'package:hey_notes/models/category.dart';
import 'package:hey_notes/providers/category_provider.dart';

class CategorySelectionSheet extends ConsumerStatefulWidget {
  final String? selectedCategoryID;

  final Function(Category? selected) onSave;

  const CategorySelectionSheet({
    super.key,
    required this.selectedCategoryID,

    required this.onSave,
  });

  @override
  ConsumerState<CategorySelectionSheet> createState() =>
      _CategorySelectionSheetState();
}

class _CategorySelectionSheetState
    extends ConsumerState<CategorySelectionSheet> {
  late String? _selectedCategoryID;

  @override
  void initState() {
    super.initState();
    _selectedCategoryID = widget.selectedCategoryID;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final categories = ref.read(categoryProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      height: size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 10, width: 10),
              Text(
                'Category',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                height: 24,
                width: 24,
                decoration: const BoxDecoration(
                  color: AppColors.lightGrey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_outlined, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  onTap: () {
                    setState(() {
                      _selectedCategoryID = _selectedCategoryID == category.name
                          ? null
                          : category.name;
                    });
                  },
                  leading: Text(
                    category.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  trailing: Icon(
                    _selectedCategoryID == category.name
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: _selectedCategoryID == category.name
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          SafeArea(
            bottom: false,
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final cat = categories.firstWhere(
                    (e) => e.name == _selectedCategoryID,
                  );
                  widget.onSave(cat);
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.textBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const Gap(UIHelpers.lg),
        ],
      ),
    );
  }
}
