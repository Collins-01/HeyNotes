import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/core/services/notes_service.dart';
import '../models/note.dart';

final noteProvider = StateNotifierProvider<NoteNotifier, List<Note>>((ref) {
  return NoteNotifier();
});

class NoteNotifier extends StateNotifier<List<Note>> {
  NoteNotifier() : super([]) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    state = NotesService.getAllNotes();
  }

  Future<void> addNote(Note note) async {
    await NotesService.addNote(note);
    state = [...state, note];
  }

  Future<void> updateNote(Note updatedNote) async {
    await NotesService.updateNote(updatedNote);
    state = [
      for (final note in state)
        if (note.id == updatedNote.id) updatedNote else note,
    ];
  }

  Future<void> deleteNote(String id) async {
    await NotesService.deleteNote(id);
    state = state.where((note) => note.id != id).toList();
  }
}
