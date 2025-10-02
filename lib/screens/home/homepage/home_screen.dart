import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/core/theme/app_colors.dart';
import 'package:hey_notes/models/note.dart';
import 'package:hey_notes/providers/category_provider.dart';
import 'package:hey_notes/extension/date_extension.dart';
import 'package:hey_notes/screens/home/components/components.dart';
import 'package:hey_notes/screens/home/homepage/homepage_viewmodel.dart';
import 'package:hey_notes/screens/notes_page/note_view_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final vm = ref.read(homepageViewModelProvider.notifier);
    final state = ref.watch(homepageViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: SlideInLeft(
          child: Text.rich(
            TextSpan(
              text: state.selectedDate.year.toString(),
              children: [
                TextSpan(
                  text: ' ${state.selectedDate.month}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.black,
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search for notes',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          SizedBox(
            height: 60,
            width: double.infinity,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: DateTime(
                DateTime.now().year,
                DateTime.now().month + 1,
                0,
              ).day,
              itemBuilder: (context, index) {
                final day = index + 1;
                final date = DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  day,
                );
                final dayName = date.toDayStringValue;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      vm.setDate(date);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: day == state.selectedDate.day
                            ? AppColors.black
                            : null,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(dayName, style: const TextStyle(fontSize: 12)),
                          Text(
                            day.toString(),
                            style: TextStyle(
                              fontWeight: day == state.selectedDate.day
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Visibility(
            visible: categories.isNotEmpty,
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ...categories.map(
                      (category) => CategoryButton(
                        category: category,
                        isSelected: state.selectedCategoryID == category.id,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 8,
                mainAxisExtent: 8,
              ),
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                final note = state.notes[index];
                return NoteCard(note: note);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteViewScreen(note: Note.empty()),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
