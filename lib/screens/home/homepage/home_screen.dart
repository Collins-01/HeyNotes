import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hey_notes/core/theme/app_colors.dart';
import 'package:hey_notes/core/utils/debounce.dart';
import 'package:hey_notes/core/utils/ui_helpers.dart';
import 'package:hey_notes/extension/extension.dart';
import 'package:hey_notes/models/note.dart';
import 'package:hey_notes/providers/category_provider.dart';
import 'package:hey_notes/screens/home/components/category_button.dart';
import 'package:hey_notes/screens/home/components/notes_card.dart';
import 'package:hey_notes/screens/home/homepage/homepage_viewmodel.dart';
import 'package:hey_notes/screens/notes_page/note_view_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late TextEditingController _searchController;
  // Create an instance
  final _searchDebouncer = Debouncer(
    duration: const Duration(milliseconds: 500),
  );

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homepageViewModelProvider.notifier).onInit();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final vm = ref.read(homepageViewModelProvider.notifier);
    final state = ref.watch(homepageViewModelProvider);
    return Scaffold(
      backgroundColor: context.isDarkMode ? AppColors.black : AppColors.white,
      appBar: AppBar(
        backgroundColor: context.isDarkMode ? AppColors.black : AppColors.white,
        centerTitle: false,
        title: SlideInLeft(
          child: Padding(
            padding: const EdgeInsets.only(left: UIHelpers.scaffoldPadding),
            child: Text.rich(
              TextSpan(
                text: state.selectedDate.year.toString(),
                children: [
                  TextSpan(
                    text: ' ${state.selectedDate.toMonthStringValue}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UIHelpers.scaffoldPadding,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                // color: context.isDarkMode ? AppColors.black : AppColors.white,
                color: AppColors.background,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _searchDebouncer.run(() {
                    vm.searchNotes(value);
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search for notes',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.all(UIHelpers.scaffoldPadding),
                ),
              ),
            ),
          ),
          const Gap(UIHelpers.sm),
          SizedBox(
            height: 85,
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
                  padding: const EdgeInsets.symmetric(horizontal: UIHelpers.sm),
                  child: GestureDetector(
                    onTap: () {
                      vm.setDate(date);
                    },
                    child: AnimatedContainer(
                      width: 65,
                      duration: UIHelpers.slowDuration,

                      curve: Curves.linear,
                      padding: const EdgeInsets.all(UIHelpers.md),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: day != state.selectedDate.day
                              ? AppColors.black.withValues(alpha: 0.2)
                              : Colors.transparent,
                        ),
                        color: day == state.selectedDate.day
                            ? AppColors.black
                            : null,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dayName,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: day == state.selectedDate.day
                                      ? AppColors.white
                                      : null,
                                ),
                          ),
                          const Gap(UIHelpers.xs),
                          Text(
                            day.toString(),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: day == state.selectedDate.day
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: day == state.selectedDate.day
                                      ? AppColors.white
                                      : null,
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
          const Gap(UIHelpers.lg),
          Visibility(
            visible: categories.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(left: UIHelpers.scaffoldPadding),
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
                          onTap: () {
                            vm.setCategory(category.id);
                          },
                          category: category,
                          isSelected: state.selectedCategoryID == category.id,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (state.notes.isNotEmpty) ...[
            const Gap(UIHelpers.lg),
            Expanded(
              child: GridView.builder(
                itemCount: state.notes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio:
                      0.8, // Adjust this value to control the width/height ratio
                  mainAxisExtent: 200, // Fixed height of 200 logical pixels
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                // padding: const EdgeInsets.all(8.0),
                itemBuilder: (context, index) {
                  final note = state.notes[index];
                  return NoteCard(note: note);
                },
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
