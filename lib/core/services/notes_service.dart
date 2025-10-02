import 'package:hey_notes/models/note.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotesService {
  static const String _notesBox = 'notes_box';

  Future<void> init() async {
    // Hive initialization and adapter registration is now handled in main.dart
    await Hive.openBox<Note>(_notesBox);
  }

  Box<Note> get _notesBoxInstance => Hive.box<Note>(_notesBox);

  // CRUD Operations
  Future<void> addNote(Note note) async {
    await _notesBoxInstance.put(note.id, note);
  }

  Future<void> updateNote(Note note) async {
    await _notesBoxInstance.put(note.id, note);
  }

  Future<void> deleteNote(String id) async {
    await _notesBoxInstance.delete(id);
  }

  Note? getNote(String id) {
    return _notesBoxInstance.get(id);
  }

  List<Note> getAllNotes() {
    return _notesBoxInstance.values.toList();
  }

  Stream<List<Note>> watchNotes() {
    return _notesBoxInstance.watch().map((_) => getAllNotes());
  }
}
