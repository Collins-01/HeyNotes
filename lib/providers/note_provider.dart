import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

final noteProvider = StateNotifierProvider<NoteNotifier, List<Note>>((ref) {
  return NoteNotifier();
});

class NoteNotifier extends StateNotifier<List<Note>> {
  NoteNotifier() : super([]) {
    loadNotes();
  }
  
  Future<void> loadNotes() async {
    state = StorageService.getAllNotes();
  }
  
  Future<void> addNote(Note note) async {
    await StorageService.addNote(note);
    state = [...state, note];
  }
  
  Future<void> updateNote(Note updatedNote) async {
    await StorageService.updateNote(updatedNote);
    state = [
      for (final note in state)
        if (note.id == updatedNote.id) updatedNote else note
    ];
  }
  
  Future<void> deleteNote(String id) async {
    await StorageService.deleteNote(id);
    state = state.where((note) => note.id != id).toList();
  }
}
