import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';

class StorageService {
  static const String _notesBox = 'notes_box';
  
  static Future<void> init() async {
    // Hive initialization and adapter registration is now handled in main.dart
    await Hive.openBox<Note>(_notesBox);
  }
  
  static Box<Note> get _notesBoxInstance => Hive.box<Note>(_notesBox);
  
  // CRUD Operations
  static Future<void> addNote(Note note) async {
    await _notesBoxInstance.put(note.id, note);
  }
  
  static Future<void> updateNote(Note note) async {
    await note.save();
  }
  
  static Future<void> deleteNote(String id) async {
    await _notesBoxInstance.delete(id);
  }
  
  static Note? getNote(String id) {
    return _notesBoxInstance.get(id);
  }
  
  static List<Note> getAllNotes() {
    return _notesBoxInstance.values.toList();
  }
  
  static Stream<List<Note>> watchNotes() {
    return _notesBoxInstance.watch().map((_) => getAllNotes());
  }
}
