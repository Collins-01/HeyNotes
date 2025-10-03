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

    // Add default categories if the box is empty
    if (_categoriesBox.isEmpty) {
      await _addDefaultCategories();
    }
  }

  Future<void> _addDefaultCategories() async {
    final defaultCategories = [
      Category(name: 'All'),
      Category(name: 'Personal'),
      Category(name: 'Work'),
      Category(name: 'Ideas'),
      Category(name: 'To Do'),
      Category(name: 'Shopping'),
      Category(name: 'Favorites'),
      Category(name: 'Important'),
      Category(name: 'Travel'),
      Category(name: 'Recipes'),
      Category(name: 'Other'),
    ];

    for (var category in defaultCategories) {
      await _categoriesBox.put(category.name, category);
    }
  }

  /// Adds or updates a category in the database
  Future<void> addCategory(Category category) async {
    await _categoriesBox.put(category.name, category);
  }

  /// Returns all categories from the database
  List<Category> getAllCategories() {
    return _categoriesBox.values.toList();
  }

  /// Returns a single category by its name
  Category? getCategory(String name) {
    return _categoriesBox.get(name);
  }

  /// Deletes a category by its name
  Future<void> deleteCategory(String name) async {
    await _categoriesBox.delete(name);
  }

  /// Clears all categories from the database
  Future<void> clearAll() async {
    await _categoriesBox.clear();
  }

  /// Returns the number of categories
  int get categoriesCount => _categoriesBox.length;

  /// Returns a stream of box events for real-time updates
  Stream<BoxEvent> watchCategories() {
    return _categoriesBox.watch();
  }

  /// Closes the database
  Future<void> close() async {
    await _categoriesBox.close();
  }
}
