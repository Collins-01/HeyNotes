import 'package:hive/hive.dart';
import 'package:hey_notes/models/category.dart';

class CategoryService {
  static const String _boxName = 'categories';
  late Box<Category> _categoriesBox;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    _categoriesBox = await Hive.openBox<Category>(_boxName);
  }

  // Add or update a category
  Future<void> saveCategory(Category category) async {
    await _categoriesBox.put(category.id, category);
  }

  // Get all categories
  List<Category> getAllCategories() {
    return _categoriesBox.values.toList();
  }

  // Get a single category by ID
  Category? getCategory(String id) {
    return _categoriesBox.get(id);
  }

  // Delete a category
  Future<void> deleteCategory(String id) async {
    await _categoriesBox.delete(id);
  }

  // Clear all categories
  Future<void> clearAll() async {
    await _categoriesBox.clear();
  }

  // Get categories count
  int get categoriesCount => _categoriesBox.length;

  // Stream of categories for real-time updates
  Stream<BoxEvent> watchCategories() {
    return _categoriesBox.watch();
  }

  // Close the box when done
  Future<void> close() async {
    await _categoriesBox.close();
  }
}
