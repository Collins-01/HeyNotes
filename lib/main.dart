import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/core/services/pdf_service.dart';
import 'package:hey_notes/core/services/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/splash/splash_screen.dart';
import 'models/note.dart';
import 'models/category.dart';
import 'service_locator.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize PDF fonts
  await PdfExportService.initializeFonts();

  /// setup locator
  setupLocator();

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
    await sl.get<NotesService>().init();

    // Initialize category service
    await sl.get<CategoryService>().init();

    // Run the app with providers
    runApp(
      ProviderScope(
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
    log('Error initializing app: $e');
    log('Stack trace: $stackTrace');

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
                Text(e.toString(), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
