import 'package:hive/hive.dart';
import 'package:hey_notes/models/category.dart';
import 'package:uuid/uuid.dart';

class CategoryService {
  static const String _boxName = 'categories';
  late Box<Category> _categoriesBox;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    _categoriesBox = await Hive.openBox<Category>(_boxName);

    // Add default categories if the box is empty
    if (_categoriesBox.isEmpty) {
      await _addDefaultCategories();
    }
  }

  Future<void> _addDefaultCategories() async {
    final defaultCategories = [
      Category(id: const Uuid().v4(), name: 'Personal'),
      Category(id: const Uuid().v4(), name: 'Work'),
      Category(id: const Uuid().v4(), name: 'Ideas'),
      Category(id: const Uuid().v4(), name: 'To Do'),
      Category(id: const Uuid().v4(), name: 'Shopping'),
      Category(id: const Uuid().v4(), name: 'Meetings'),
      Category(id: const Uuid().v4(), name: 'Projects'),
      Category(id: const Uuid().v4(), name: 'Learning'),
      Category(id: const Uuid().v4(), name: 'Recipes'),
      Category(id: const Uuid().v4(), name: 'Travel'),
    ];

    await _categoriesBox.putAll({
      for (var category in defaultCategories) category.id: category,
    });
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
