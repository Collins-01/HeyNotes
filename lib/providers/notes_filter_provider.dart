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
  
  void updateCategoryFilter(String? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  List<Note> filterAndSortNotes(List<Note> notes) {
    // Filter notes based on search query and category
    var filteredNotes = notes.where((note) {
      // Filter by search query
      if (state.searchQuery.isNotEmpty) {
        final query = state.searchQuery.toLowerCase();
        if (!note.title.toLowerCase().contains(query) &&
            !note.content.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Filter by category
      if (state.categoryId != null && note.categoryId != state.categoryId) {
        return false;
      }
      
      return true;
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
  final String? categoryId;

  const NotesFilterState({
    this.searchQuery = '',
    this.sortOption = SortOption.newestFirst,
    this.categoryId,
  });

  NotesFilterState copyWith({
    String? searchQuery,
    SortOption? sortOption,
    String? categoryId,
  }) {
    return NotesFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      categoryId: categoryId ?? this.categoryId,
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
