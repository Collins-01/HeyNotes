import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/core/services/categories_service.dart';
import 'package:hey_notes/core/utils/logger.dart';
import 'package:hey_notes/service_locator.dart';
import 'package:hive/hive.dart';
import '../models/category.dart';

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<Category>>(
      (ref) => CategoryNotifier(sl<CategoryService>()),
    );

class CategoryNotifier extends StateNotifier<List<Category>> {
  final CategoryService _categoryService;

  CategoryNotifier(this._categoryService) : super([]) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    state = _categoryService.getAllCategories();
  }

  Future<void> getAllCategories() async {
    state = _categoryService.getAllCategories();
    AppLogger.v('Categories loaded: ${state.length}');
  }

  Future<void> addCategory(String name) async {
    final newCategory = Category(name: name);
    await _categoryService.addCategory(newCategory);
    //reload categories state to get updated value
    state = _categoryService.getAllCategories();
  }

  Future<void> updateCategory(String oldName, String newName) async {
    final category = _categoryService.getCategory(oldName);
    if (category != null) {
      // Delete old category and create a new one with updated name
      await _categoryService.deleteCategory(oldName);
      final updatedCategory = Category(name: newName);
      await _categoryService.addCategory(updatedCategory);
      //reload categories state to get updated value
      state = _categoryService.getAllCategories();
    }
  }

  Future<void> deleteCategory(String name) async {
    await _categoryService.deleteCategory(name);
    //reload categories state to get updated value
    state = _categoryService.getAllCategories();
  }

  Category? getCategory(String name) {
    return _categoryService.getCategory(name);
  }

  Stream<BoxEvent> watchCategories() {
    return _categoryService.watchCategories();
  }
}
