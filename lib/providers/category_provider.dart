import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier() : super([]);

  void addCategory(String name, int color) {
    final newCategory = Category(
      id: const Uuid().v4(),
      name: name,
      color: color,
    );
    state = [...state, newCategory];
  }

  void updateCategory(String id, String name, int color) {
    state = [
      for (final category in state)
        if (category.id == id)
          category.copyWith(name: name, color: color)
        else
          category,
    ];
  }

  void deleteCategory(String id) {
    state = state.where((category) => category.id != id).toList();
  }

  Category? getCategory(String id) {
    try {
      return state.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, List<Category>>(
  (ref) => CategoryNotifier(),
);
