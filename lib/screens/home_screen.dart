import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/note.dart';
import '../models/category.dart';
import '../providers/note_provider.dart';
import '../providers/notes_filter_provider.dart';
import '../providers/category_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/search_bar.dart' as custom;
import '../widgets/category_chip.dart';
import '../widgets/add_category_modal.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(noteProvider);
    final categories = ref.watch(categoryProvider);
    final filterState = ref.watch(notesFilterProvider);
    
    return _buildContent(context, ref, notes, categories, filterState);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Note> notes,
    List<Category> categories,
    NotesFilterState filterState,
  ) {
    final theme = Theme.of(context);
    final greeting = _getGreeting();
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Hey Notes',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: custom.SearchBar(
              hintText: 'Search notes...',
            ),
          ),
          
          // Categories Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        showAddCategoryModal(context);
                      },
                      child: const Text('+ Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // All category
                      CategoryChip(
                        label: 'All',
                        isSelected: filterState.categoryId == null,
                        onSelected: () {
                          ref.read(notesFilterProvider.notifier).updateCategoryFilter(null);
                        },
                      ),
                      
                      // Other categories
                      ...categories.map((category) => CategoryChip(
                        label: category.name,
                        isSelected: filterState.categoryId == category.id,
                        onSelected: () {
                          ref.read(notesFilterProvider.notifier).updateCategoryFilter(category.id);
                        },
                        backgroundColor: Color(category.color),
                      )).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Notes Grid
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notes yet',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to create your first note',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
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
