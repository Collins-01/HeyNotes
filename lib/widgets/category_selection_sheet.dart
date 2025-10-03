import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              Text(
                'Select Categories',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  // TODO: Implement add new category
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                final category = categories[index + 1];
                if (index == 0) {
                  return Row(
                    children: [Icon(Icons.add_circle_outline_rounded)],
                  );
                }
                return ListTile(
                  leading: Text(category.name),
                  trailing: Icon(
                    _selectedCategoryID == category.name
                        ? Icons.check_circle
                        : Icons.circle,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
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
        ],
      ),
    );
  }
}
