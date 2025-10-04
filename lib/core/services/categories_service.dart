import 'package:hive/hive.dart';
import 'package:hey_notes/core/utils/logger.dart';
import 'package:hey_notes/models/category.dart';

class CategoryService {
  static const String _boxName = 'categories';
  late Box<Category> _categoriesBox;

  Future<void> init() async {
    try {
      AppLogger.i('Initializing CategoryService...');
      if (!Hive.isAdapterRegistered(1)) {
        AppLogger.d('Registering CategoryAdapter');
        Hive.registerAdapter(CategoryAdapter());
      }
      
      AppLogger.d('Opening Hive box: $_boxName');
      _categoriesBox = await Hive.openBox<Category>(_boxName);
      AppLogger.i('Successfully opened Hive box: $_boxName');

      // Add default categories if the box is empty
      if (_categoriesBox.isEmpty) {
        AppLogger.d('Box is empty, adding default categories');
        // await _addDefaultCategories();
      } else {
        AppLogger.d('Found ${_categoriesBox.length} existing categories');
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error initializing CategoryService', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _addDefaultCategories() async {
    try {
      AppLogger.i('Adding default categories');
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

      AppLogger.d('Adding ${defaultCategories.length} default categories');
      for (var category in defaultCategories) {
        await _categoriesBox.put(category.name, category);
        AppLogger.v('Added category: ${category.name}');
      }
      AppLogger.i('Successfully added ${defaultCategories.length} default categories');
    } catch (e, stackTrace) {
      AppLogger.e('Error adding default categories', e, stackTrace);
      rethrow;
    }
  }

  /// Adds or updates a category in the database
  Future<void> addCategory(Category category) async {
    try {
      AppLogger.i('Adding/Updating category: ${category.name}');
      await _categoriesBox.put(category.name, category);
      AppLogger.d('Successfully saved category: ${category.name}');
    } catch (e, stackTrace) {
      AppLogger.e('Error saving category: ${category.name}', e, stackTrace);
      rethrow;
    }
  }

  /// Returns all categories from the database
  List<Category> getAllCategories() {
    try {
      final categories = _categoriesBox.values.toList();
      AppLogger.v('Retrieved ${categories.length} categories');
      return categories;
    } catch (e, stackTrace) {
      AppLogger.e('Error retrieving categories', e, stackTrace);
      rethrow;
    }
  }

  /// Returns a single category by its name
  Category? getCategory(String name) {
    try {
      final category = _categoriesBox.get(name);
      if (category != null) {
        AppLogger.v('Retrieved category: $name');
      } else {
        AppLogger.w('Category not found: $name');
      }
      return category;
    } catch (e, stackTrace) {
      AppLogger.e('Error retrieving category: $name', e, stackTrace);
      rethrow;
    }
  }

  /// Deletes a category by its name
  Future<void> deleteCategory(String name) async {
    try {
      AppLogger.i('Deleting category: $name');
      await _categoriesBox.delete(name);
      AppLogger.d('Successfully deleted category: $name');
    } catch (e, stackTrace) {
      AppLogger.e('Error deleting category: $name', e, stackTrace);
      rethrow;
    }
  }

  /// Clears all categories from the database
  Future<void> clearAll() async {
    try {
      AppLogger.w('Clearing all categories');
      await _categoriesBox.clear();
      AppLogger.i('Successfully cleared all categories');
    } catch (e, stackTrace) {
      AppLogger.e('Error clearing categories', e, stackTrace);
      rethrow;
    }
  }

  /// Returns the number of categories
  int get categoriesCount {
    final count = _categoriesBox.length;
    AppLogger.v('Current category count: $count');
    return count;
  }

  /// Returns a stream of box events for real-time updates
  Stream<BoxEvent> watchCategories() {
    AppLogger.v('Setting up category watch stream');
    return _categoriesBox.watch();
  }

  /// Closes the database
  Future<void> close() async {
    try {
      AppLogger.i('Closing category database');
      await _categoriesBox.close();
      AppLogger.i('Successfully closed category database');
    } catch (e, stackTrace) {
      AppLogger.e('Error closing category database', e, stackTrace);
      rethrow;
    }
  }
}
