import 'package:hey_notes/models/note.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class NotesService {
  static const String _notesBox = 'notes_box';

  Future<void> init() async {
    // Hive initialization and adapter registration is now handled in main.dart
    final box = await Hive.openBox<Note>(_notesBox);
    
    // Add sample notes if the box is empty
    if (box.isEmpty) {
      await _addSampleNotes();
    }
  }
  
  Future<void> _addSampleNotes() async {
    final now = DateTime.now();
    final sampleNotes = [
      Note(
        id: const Uuid().v4(),
        title: 'Welcome to HeyNotes!',
        content: 'Start organizing your thoughts and ideas with HeyNotes. Tap the + button to create your first note!',
        createdAt: now,
        updatedAt: now,
        color: '#FF9E9E', // Light red
        isPinned: true,
      ),
      Note(
        id: const Uuid().v4(),
        title: 'Quick Tips',
        content: '• Swipe left/right on notes to delete or archive\n• Pin important notes to keep them on top\n• Use categories to organize your notes',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        color: '#9E9EFF', // Light blue
      ),
      Note(
        id: const Uuid().v4(),
        title: 'Shopping List',
        content: '- Milk\n- Eggs\n- Bread\n- Fruits\n- Vegetables',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        color: '#9EFF9E', // Light green
      ),
      Note(
        id: const Uuid().v4(),
        title: 'Project Ideas',
        content: '1. Mobile app for task management\n2. Recipe sharing platform\n3. Personal finance tracker\n4. Learning journal app',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
        color: '#FFD700', // Gold
      ),
      Note(
        id: const Uuid().v4(),
        title: 'Book Recommendations',
        content: '• Atomic Habits by James Clear\n• Deep Work by Cal Newport\n• The Psychology of Money by Morgan Housel',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
        color: '#DDA0DD', // Plum
      ),
    ];
    
    await _notesBoxInstance.putAll({
      for (final note in sampleNotes) note.id: note,
    });
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
