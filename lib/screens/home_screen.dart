import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../providers/notes_filter_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/search_bar.dart' as custom;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(noteProvider);
    final filterState = ref.watch(notesFilterProvider);

    return notesAsync.when(
      loading: () => _buildLoading(),
      error: (error, stack) => _buildError(error),
      data: (notes) => _buildContent(context, ref, notes, filterState),
    );
  }

  Widget _buildLoading() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Widget _buildError(dynamic error) {
    return Scaffold(body: Center(child: Text('Error: $error')));
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Note> notes,
    NotesFilterState filterState,
  ) {
    final filteredNotes = ref.watch(filteredNotesProvider(notes));
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hey Notes'),
        actions: [
          // Theme toggle
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark 
                ? Icons.light_mode 
                : Icons.dark_mode),
            onPressed: () {
              final newTheme = themeMode == ThemeMode.dark 
                  ? AppThemeMode.light 
                  : AppThemeMode.dark;
              themeNotifier.setTheme(newTheme);
            },
            tooltip: 'Toggle theme',
          ),
          // Sort menu
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (sortOption) {
              ref.read(notesFilterProvider.notifier).setSortOption(sortOption);
            },
            itemBuilder: (context) => SortOption.values.map((option) {
              return PopupMenuItem<SortOption>(
                value: option,
                child: Row(
                  children: [
                    if (filterState.sortOption == option)
                      Icon(Icons.check, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(option.label),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: custom.SearchBar(
              onChanged: (query) {
                ref.read(notesFilterProvider.notifier).setSearchQuery(query);
              },
            ),
          ),
          // Notes list
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: filterState.searchQuery.isNotEmpty
                        ? const Text('No matching notes found')
                        : const Text('No notes yet. Tap + to create one!'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return NoteCard(
                        note: note,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/view',
                            arguments: note,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/edit');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
