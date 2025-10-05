import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hey_notes/core/theme/app_colors.dart';
import 'package:hey_notes/core/utils/constants.dart';
import 'package:hey_notes/core/utils/ui_helpers.dart';
import 'package:hey_notes/models/category.dart';
import 'package:hey_notes/providers/category_provider.dart';
import 'package:hey_notes/widgets/buttons/filled_button.dart';
import 'package:swift_alert/swift_alert.dart';

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
  String? _selectedCategoryID;

  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategoryID =
        widget.selectedCategoryID ?? Constants.defaultCategory;
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    _categoryController.clear();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: UIHelpers.lg,
          right: UIHelpers.lg,
          top: UIHelpers.lg,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(UIHelpers.borderRadiusLg),
            topRight: Radius.circular(UIHelpers.borderRadiusLg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Category',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: UIHelpers.lg),
            TextField(
              controller: _categoryController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Enter category name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(UIHelpers.borderRadiusMd),
                  borderSide: const BorderSide(color: AppColors.lightGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(UIHelpers.borderRadiusMd),
                  borderSide: const BorderSide(color: AppColors.lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(UIHelpers.borderRadiusMd),
                  borderSide: const BorderSide(color: AppColors.textBlack),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: UIHelpers.md,
                  vertical: UIHelpers.sm,
                ),
              ),
            ),
            const SizedBox(height: UIHelpers.lg),
            SafeArea(
              child: AppFilledButton(
                text: 'Create Category',
                onPressed: () {
                  final categoryName = _categoryController.text.trim();
                  if (categoryName.isEmpty) {
                    SwiftAlert.display(
                      context,
                      message: 'Category name is required',
                      type: NotificationType.warning,
                    );
                    return;
                  }

                  /// Check against existing category name
                  final index = ref
                      .read(categoryProvider)
                      .indexWhere(
                        (category) =>
                            category.name.toLowerCase() ==
                            categoryName.toLowerCase(),
                      );

                  if (index != -1) {
                    SwiftAlert.display(
                      context,
                      message: 'Category already exists',
                      type: NotificationType.warning,
                    );
                    return;
                  }
                  if (index == -1) {
                    ref
                        .read(categoryProvider.notifier)
                        .addCategory(categoryName);
                    Navigator.pop(context);
                    return;
                  }
                },
              ),
            ),
            const Gap(UIHelpers.lg),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final categories = ref.watch(categoryProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      height: size.height * 0.6,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(UIHelpers.borderRadiusLg),
          topRight: Radius.circular(UIHelpers.borderRadiusLg),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(UIHelpers.xs),
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
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 24,
                  width: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.lightGrey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_outlined, size: 16),
                ),
              ),
            ],
          ),
          const Gap(UIHelpers.md),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) =>
                  const Divider(color: AppColors.lightGrey, thickness: .5),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: UIHelpers.md),
                    child: ListTile(
                      leading: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.textBlack,
                      ),
                      title: Text(
                        'Add a new category',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textBlack,
                        ),
                      ),
                      trailing: const CheckButton(isChecked: false),
                      onTap: () {
                        _showAddCategoryDialog(context);
                      },
                    ),
                  );
                }
                final category = categories[index - 1];
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
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: CheckButton(
                    isChecked: _selectedCategoryID == category.name,
                    onTap: () {
                      setState(() {
                        _selectedCategoryID =
                            _selectedCategoryID == category.name
                            ? null
                            : category.name;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          SafeArea(
            bottom: false,
            child: AppFilledButton(
              text: 'Save',
              onPressed: () {
                try {
                  // If no category is selected, use 'All' as default
                  if (_selectedCategoryID == null) {
                    widget.onSave(Category(name: Constants.defaultCategory));
                    Navigator.of(context).pop();
                    return;
                  }

                  // Try to find the selected category
                  final category = categories.firstWhere(
                    (e) => e.name == _selectedCategoryID,
                    orElse: () => Category(
                      name: Constants.defaultCategory,
                    ), // Default to 'All' if not found
                  );

                  widget.onSave(category);
                  Navigator.of(context).pop();
                } catch (e) {
                  // Fallback to 'All' category in case of any error
                  if (mounted) {
                    widget.onSave(Category(name: Constants.defaultCategory));
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ),
          const Gap(UIHelpers.lg),
        ],
      ),
    );
  }
}

class CheckButton extends StatelessWidget {
  final bool isChecked;
  final VoidCallback? onTap;
  const CheckButton({super.key, required this.isChecked, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: UIHelpers.fastDuration,
        height: 24,
        width: 24,
        decoration: BoxDecoration(
          color: isChecked ? AppColors.textBlack : null,
          shape: BoxShape.circle,
          border: Border.all(
            color: isChecked ? AppColors.textBlack : AppColors.lightGrey,
          ),
        ),
        child: Icon(
          Icons.check_rounded,
          size: 16,
          color: isChecked
              ? AppColors.white
              : AppColors.textBlack.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
