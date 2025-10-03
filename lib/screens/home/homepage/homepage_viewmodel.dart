import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/enums/note_sort.dart';
import 'package:hey_notes/models/note.dart';
import 'package:hey_notes/providers/note_provider.dart';
import 'package:hey_notes/screens/home/homepage/homepage_state.dart';

class HomepageViewmodel extends StateNotifier<HomepageState> {
  final Ref ref;

  HomepageViewmodel(this.ref) : super(HomepageState.initial());

  void onInit() async {
    final notes = ref.read(noteProvider);
    state = state.copyWith(notes: notes);
    // Apply the current sort order to the initial notes
    sortNotes(state.sortOrder);
    loadCategories();

    // reset selected category and date
    state = state.copyWith(
      selectedCategoryID: 'all',
      selectedDate: DateTime.now(),
    );
  }

  void loadCategories() {}

  void setSelectedCategoryID(String id) {
    state = state.copyWith(selectedCategoryID: id);
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    filterByDate();
  }

  void filterByDate() {
    final notes = ref.read(noteProvider);
    final filteredNotes = notes.where((note) {
      return note.createdAt.year == state.selectedDate.year &&
          note.createdAt.month == state.selectedDate.month &&
          note.createdAt.day == state.selectedDate.day;
    }).toList();
    state = state.copyWith(notes: filteredNotes);
  }

  void searchNotes(String query) {
    if (query.isEmpty) {
      // If search query is empty, show all notes
      final allNotes = ref.read(noteProvider);
      state = state.copyWith(notes: allNotes, searchQuery: '');
      return;
    }

    final notes = ref.read(noteProvider);
    final searchQuery = query.toLowerCase();

    final filteredNotes = notes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(searchQuery);
      final contentMatch = note.content.toLowerCase().contains(searchQuery);
      return titleMatch || contentMatch;
    }).toList();

    state = state.copyWith(notes: filteredNotes, searchQuery: searchQuery);
  }

  void setCategory(String id) {
    state = state.copyWith(selectedCategoryID: id);
    filterByCategory();
  }

  void filterByCategory() {
    final notes = ref.read(noteProvider);
    if (state.selectedCategoryID?.toLowerCase() == 'all') {
      state = state.copyWith(notes: notes);
      return;
    }
    final filteredNotes = notes.where((note) {
      return note.categoryId == state.selectedCategoryID;
    }).toList();
    state = state.copyWith(notes: filteredNotes);
  }

  void sortNotes(NoteSort sortBy) {
    final notes = List<Note>.from(state.notes);

    switch (sortBy) {
      case NoteSort.newestFirst:
        notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case NoteSort.oldestFirst:
        notes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case NoteSort.byTitle:
        notes.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    state = state.copyWith(notes: notes, sortOrder: sortBy);
  }
}

final homepageViewModelProvider =
    StateNotifierProvider.autoDispose<HomepageViewmodel, HomepageState>((ref) {
      return HomepageViewmodel(ref);
    });
