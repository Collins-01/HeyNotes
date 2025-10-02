import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/splash_screen.dart';
import 'models/note.dart';
import 'models/category.dart';
import 'services/category_hive_service.dart';
import 'services/storage_service.dart';
import 'providers/category_provider.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(CategoryAdapter());
    
    // Open Hive boxes
    await Future.wait([
      Hive.openBox<Note>('notes_box'),
      Hive.openBox<Category>('categories'),
    ]);
    
    // Initialize storage service
    await StorageService.init();
    
    // Initialize category service
    final categoryService = CategoryHiveService();
    await categoryService.init();
    
    // Run the app with providers
    runApp(
      ProviderScope(
        overrides: [
          categoryHiveServiceProvider.overrideWithValue(categoryService),
          categoryProvider.overrideWith((ref) {
            final service = ref.watch(categoryHiveServiceProvider);
            return CategoryNotifier(service);
          }),
        ],
        child: MaterialApp(
          title: 'HeyNotes',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  } catch (e, stackTrace) {
    print('Error initializing app: $e');
    print('Stack trace: $stackTrace');
    
    // Show error UI if initialization fails
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Error initializing app',
                  style: TextStyle(fontSize: 20, color: Colors.red),
                ),
                const SizedBox(height: 20),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
