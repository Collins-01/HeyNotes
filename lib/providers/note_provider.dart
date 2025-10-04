import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/core/services/notes_service.dart';
import 'package:hey_notes/service_locator.dart';
import '../models/note.dart';

final noteProvider = StateNotifierProvider<NoteNotifier, List<Note>>((ref) {
  return NoteNotifier(sl<NotesService>());
});

class NoteNotifier extends StateNotifier<List<Note>> {
  final NotesService _notesService;
  NoteNotifier(this._notesService) : super([]) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    state = _notesService.getAllNotes();
  }

  Future<void> addNote(Note note) async {
    await _notesService.addNote(note);
    state = [...state, note];
  }

  Future<void> updateNote(Note updatedNote) async {
    await _notesService.updateNote(updatedNote);
    state = [
      for (final note in state)
        if (note.id == updatedNote.id) updatedNote else note,
    ];
  }

  Future<void> deleteNote(String id) async {
    await _notesService.deleteNote(id);
    state = state.where((note) => note.id != id).toList();
  }

  Future<void> getAllNotes() async {
    state = _notesService.getAllNotes();
  }
}
