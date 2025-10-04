import 'package:hey_notes/core/utils/logger.dart';
import 'package:hey_notes/models/note.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class NotesService {
  static const String _notesBox = 'notes_box';

  Future<void> init() async {
    try {
      AppLogger.i('Initializing NotesService...');
      // Hive initialization and adapter registration is now handled in main.dart
      AppLogger.d('Opening Hive box: $_notesBox');
      final box = await Hive.openBox<Note>(_notesBox);

      // Add sample notes if the box is empty
      if (box.isEmpty) {
        AppLogger.d('Box is empty, adding sample notes');
        await _addSampleNotes();
      } else {
        AppLogger.d('Found ${box.length} existing notes');
      }
      AppLogger.i('NotesService initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.e('Error initializing NotesService', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _addSampleNotes() async {
    try {
      AppLogger.i('Adding sample notes');
      final now = DateTime.now();
      final sampleNotes = [
        Note(
          id: const Uuid().v4(),
          title: 'Welcome to HeyNotes!',
          content:
              'Start organizing your thoughts and ideas with HeyNotes. Tap the + button to create your first note!',
          createdAt: now,
          updatedAt: now,
          color: '#FF9E9E', // Light red
          isPinned: true,
        ),
        Note(
          id: const Uuid().v4(),
          title: 'Quick Tips',
          content:
              '• Swipe left/right on notes to delete or archive\n• Pin important notes to keep them on top\n• Use categories to organize your notes',
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
          content:
              '1. Mobile app for task management\n2. Recipe sharing platform\n3. Personal finance tracker\n4. Learning journal app',
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now.subtract(const Duration(days: 3)),
          color: '#FFD700', // Gold
        ),
        Note(
          id: const Uuid().v4(),
          title: 'Book Recommendations',
          content:
              '• Atomic Habits by James Clear\n• Deep Work by Cal Newport\n• The Psychology of Money by Morgan Housel',
          createdAt: now.subtract(const Duration(days: 4)),
          updatedAt: now.subtract(const Duration(days: 4)),
          color: '#DDA0DD', // Plum
        ),
      ];

      AppLogger.d('Adding ${sampleNotes.length} sample notes');
      await _notesBoxInstance.putAll({
        for (final note in sampleNotes) note.id: note,
      });
      AppLogger.i('Successfully added ${sampleNotes.length} sample notes');
    } catch (e, stackTrace) {
      AppLogger.e('Error adding sample notes', e, stackTrace);
      rethrow;
    }
  }

  Box<Note> get _notesBoxInstance {
    try {
      final box = Hive.box<Note>(_notesBox);
      AppLogger.v('Accessing notes box (${box.length} notes)');
      return box;
    } catch (e, stackTrace) {
      AppLogger.e('Error accessing notes box', e, stackTrace);
      rethrow;
    }
  }

  // CRUD Operations
  Future<void> addNote(Note note) async {
    try {
      AppLogger.i('Adding new note: ${note.title}');
      await _notesBoxInstance.put(note.id, note);
      AppLogger.d('Successfully added note: ${note.id}');
    } catch (e, stackTrace) {
      AppLogger.e('Error adding note: ${note.id}', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      AppLogger.i('Updating note: ${note.id}');
      await _notesBoxInstance.put(note.id, note);
      AppLogger.d('Successfully updated note: ${note.id}');
    } catch (e, stackTrace) {
      AppLogger.e('Error updating note: ${note.id}', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      AppLogger.i('Deleting note: $id');
      await _notesBoxInstance.delete(id);
      AppLogger.d('Successfully deleted note: $id');
    } catch (e, stackTrace) {
      AppLogger.e('Error deleting note: $id', e, stackTrace);
      rethrow;
    }
  }

  Note? getNote(String id) {
    try {
      final note = _notesBoxInstance.get(id);
      if (note != null) {
        AppLogger.v('Retrieved note: $id');
      } else {
        AppLogger.w('Note not found: $id');
      }
      return note;
    } catch (e, stackTrace) {
      AppLogger.e('Error retrieving note: $id', e, stackTrace);
      rethrow;
    }
  }

  List<Note> getAllNotes() {
    try {
      final notes = _notesBoxInstance.values.toList();
      AppLogger.v('Retrieved all notes (${notes.length} total)');
      return notes;
    } catch (e, stackTrace) {
      AppLogger.e('Error retrieving all notes', e, stackTrace);
      rethrow;
    }
  }

  Stream<List<Note>> watchNotes() {
    try {
      AppLogger.v('Setting up notes watch stream');
      return _notesBoxInstance.watch().map((_) {
        final notes = getAllNotes();
        AppLogger.v('Notes stream updated (${notes.length} notes)');
        return notes;
      });
    } catch (e, stackTrace) {
      AppLogger.e('Error setting up notes watch stream', e, stackTrace);
      rethrow;
    }
  }
}
