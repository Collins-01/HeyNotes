import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../services/category_hive_service.dart';

final categoryHiveServiceProvider = Provider<CategoryHiveService>((ref) {
  throw UnimplementedError('CategoryHiveService not initialized');
});

final categoryProvider = StateNotifierProvider<CategoryNotifier, List<Category>>(
  (ref) => throw UnimplementedError('CategoryNotifier not initialized'),
);

class CategoryNotifier extends StateNotifier<List<Category>> {
  final CategoryHiveService _hiveService;
  
  CategoryNotifier(this._hiveService) : super([]) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    state = _hiveService.getAllCategories();
  }

  Future<void> addCategory(String name, int color) async {
    final newCategory = Category(
      id: const Uuid().v4(),
      name: name,
      color: color,
    );
    
    await _hiveService.saveCategory(newCategory);
    state = _hiveService.getAllCategories();
  }

  Future<void> updateCategory(String id, String name, int color) async {
    final category = _hiveService.getCategory(id);
    if (category != null) {
      final updatedCategory = category.copyWith(
        name: name,
        color: color,
      );
      await _hiveService.saveCategory(updatedCategory);
      state = _hiveService.getAllCategories();
    }
  }

  Future<void> deleteCategory(String id) async {
    await _hiveService.deleteCategory(id);
    state = _hiveService.getAllCategories();
  }

  Category? getCategory(String id) {
    return _hiveService.getCategory(id);
  }
  
  Stream<BoxEvent> watchCategories() {
    return _hiveService.watchCategories();
  }
}
