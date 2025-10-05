import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/core/utils/constants.dart';
import 'package:hey_notes/core/utils/logger.dart';
import 'package:hey_notes/enums/note_sort.dart';
import 'package:hey_notes/models/note.dart';
import 'package:hey_notes/providers/category_provider.dart';
import 'package:hey_notes/providers/note_provider.dart';
import 'package:hey_notes/screens/home/homepage/homepage_state.dart';

class HomepageViewmodel extends StateNotifier<HomepageState> {
  final Ref ref;

  HomepageViewmodel(this.ref) : super(HomepageState.initial());

  void onInit() async {
    loadNotes();
    loadCategories();
    resetFilters();
  }

  void resetFilters() {
    state = state.copyWith(
      selectedDate: DateTime.now(),
      searchQuery: '',
      notes: ref.read(noteProvider),
      sortOrder: NoteSort.newestFirst,
    );
    applyFilters();
  }

  void loadNotes() {
    ref.read(noteProvider.notifier).getAllNotes();
    AppLogger.d('Notes loaded: ${ref.read(noteProvider).length}');
    state = state.copyWith(notes: ref.read(noteProvider));
  }

  void loadCategories() {
    ref.read(categoryProvider.notifier).getAllCategories();
    final categories = ref.read(categoryProvider);
    if (categories.isNotEmpty) {
      state = state.copyWith(selectedCategoryID: categories.first.name);
    }
  }

  void setSelectedCategoryID(String id) {
    state = state.copyWith(selectedCategoryID: id);
    applyFilters();
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    applyFilters();
  }

  void searchNotes(String query) {
    state = state.copyWith(searchQuery: query);
    applyFilters();
  }

  void setCategory(String id) {
    state = state.copyWith(selectedCategoryID: id);
    applyFilters();
  }

  /// Applies all active filters to the notes list
  void applyFilters() {
    // Always get fresh notes from the provider
    final allNotes = ref.read(noteProvider);
    
    // Start with all notes and apply filters in sequence
    var filteredNotes = List<Note>.from(allNotes);

    // Apply search filter if query is not empty
    if (state.searchQuery.isNotEmpty) {
      final searchQuery = state.searchQuery.toLowerCase();
      filteredNotes = filteredNotes.where((note) {
        final titleMatch = note.title.toLowerCase().contains(searchQuery);
        final contentMatch = note.content.toLowerCase().contains(searchQuery);
        return titleMatch || contentMatch;
      }).toList();
    }

    // Apply date filter if a date is selected
    final selectedDate = state.selectedDate;
    filteredNotes = filteredNotes.where((note) {
      return note.createdAt.year == selectedDate.year &&
          note.createdAt.month == selectedDate.month &&
          note.createdAt.day == selectedDate.day;
    }).toList();

    // Apply category filter only if a specific category is selected (not 'all' and not null)
    final selectedCategoryID = state.selectedCategoryID;
    if (selectedCategoryID != null && 
        selectedCategoryID.toLowerCase() != Constants.defaultCategory.toLowerCase()) {
      final categoryId = selectedCategoryID.toLowerCase();
      filteredNotes = filteredNotes.where((note) {
        // Include notes that match the selected category ID (case-insensitive)
        return note.categoryId?.toLowerCase() == categoryId;
      }).toList();
    }

    // Update state with filtered notes
    state = state.copyWith(notes: filteredNotes);
  }

  void sortNotes(NoteSort sortBy) {
    final notes = List<Note>.from(state.notes);

    switch (sortBy) {
      case NoteSort.newestFirst:
        notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case NoteSort.oldestFirst:
        notes.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case NoteSort.byTitle:
        notes.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }

    state = state.copyWith(notes: notes, sortOrder: sortBy);
  }

  void deleteNote(String noteId) {
    ref.read(noteProvider.notifier).deleteNote(noteId);
    state = state.copyWith(
      notes: state.notes.where((note) => note.id != noteId).toList(),
    );
  }

  void deleteCategory(String name) {
    ref.read(categoryProvider.notifier).deleteCategory(name);
    state = state.copyWith(selectedCategoryID: 'all');
    loadCategories();
  }
}

final homepageViewModelProvider =
    StateNotifierProvider.autoDispose<HomepageViewmodel, HomepageState>((ref) {
      return HomepageViewmodel(ref);
    });
