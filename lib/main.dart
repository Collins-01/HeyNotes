import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'models/note.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(NoteAdapter());
    
    // Open the Hive box
    await Hive.openBox<Note>('notes_box');
    
    // Initialize storage service
    await StorageService.init();
    
    // Run the app
    runApp(const App());
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
