import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';

enum SortOption {
  newestFirst('Newest first'),
  oldestFirst('Oldest first'),
  titleAZ('Title A-Z'),
  titleZA('Title Z-A');

  final String label;
  const SortOption(this.label);
}

class NotesFilterNotifier extends StateNotifier<NotesFilterState> {
  NotesFilterNotifier() : super(const NotesFilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortOption(SortOption sortOption) {
    state = state.copyWith(sortOption: sortOption);
  }

  List<Note> filterAndSortNotes(List<Note> notes) {
    // Filter notes based on search query
    var filteredNotes = notes.where((note) {
      if (state.searchQuery.isEmpty) return true;
      
      final query = state.searchQuery.toLowerCase();
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();

    // Sort notes based on sort option
    switch (state.sortOption) {
      case SortOption.newestFirst:
        filteredNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case SortOption.oldestFirst:
        filteredNotes.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case SortOption.titleAZ:
        filteredNotes.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.titleZA:
        filteredNotes.sort((a, b) => b.title.compareTo(a.title));
        break;
    }

    return filteredNotes;
  }
}

class NotesFilterState {
  final String searchQuery;
  final SortOption sortOption;

  const NotesFilterState({
    this.searchQuery = '',
    this.sortOption = SortOption.newestFirst,
  });

  NotesFilterState copyWith({
    String? searchQuery,
    SortOption? sortOption,
  }) {
    return NotesFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

final notesFilterProvider =
    StateNotifierProvider<NotesFilterNotifier, NotesFilterState>((ref) {
  return NotesFilterNotifier();
});

final filteredNotesProvider = Provider.family<List<Note>, List<Note>>((ref, notes) {
  final filter = ref.watch(notesFilterProvider.notifier);
  return filter.filterAndSortNotes(notes);
});
