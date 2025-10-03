import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hey_notes/app.dart';
import 'package:hey_notes/core/navigation/navigation_service.dart';
import 'package:hey_notes/core/theme/app_colors.dart';
import 'package:hey_notes/core/utils/debounce.dart';
import 'package:hey_notes/core/utils/icon_assets.dart';
import 'package:hey_notes/core/utils/ui_helpers.dart';
import 'package:hey_notes/enums/menu_action.dart';
import 'package:hey_notes/enums/note_sort.dart';
import 'package:hey_notes/extension/extension.dart';
import 'package:hey_notes/models/note.dart';
import 'package:hey_notes/providers/category_provider.dart';
import 'package:hey_notes/screens/home/components/category_button.dart';
import 'package:hey_notes/screens/home/components/notes_card.dart';
import 'package:hey_notes/screens/home/homepage/homepage_viewmodel.dart';
import 'package:hey_notes/screens/home/settings_page.dart';
import 'package:hey_notes/screens/notes_page/note_view_screen.dart';
import 'package:hey_notes/widgets/show_svg.dart';
import 'package:intl/intl.dart';

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
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, HomepageViewmodel vm) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      // Format the date to show in the app bar
      final formattedDate = DateFormat('MMMM d, y').format(picked);
      
      // Update the selected date in the viewmodel
      vm.setDate(picked);
      
      // Show a snackbar with the selected date
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Showing notes for $formattedDate'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homepageViewModelProvider);
    final vm = ref.read(homepageViewModelProvider.notifier);
    final categories = ref.watch(categoryProvider);
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
          PopupMenuButton<MenuAction>(
            icon: const Icon(Icons.more_vert),
            onSelected: (action) {
              switch (action) {
                case MenuAction.sortByDateNewest:
                  vm.sortNotes(NoteSort.newestFirst);
                  break;
                case MenuAction.sortByDateOldest:
                  vm.sortNotes(NoteSort.oldestFirst);
                  break;
                case MenuAction.sortByTitle:
                  vm.sortNotes(NoteSort.byTitle);
                  break;
                case MenuAction.selectDate:
                  _selectDate(context, vm);
                  break;
                case MenuAction.settings:
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<MenuAction>(
                value: MenuAction.sortByDateNewest,
                child: Row(
                  children: [
                    Icon(Icons.sort, size: 20),
                    SizedBox(width: 8),
                    Text('Newest First'),
                  ],
                ),
              ),
              const PopupMenuItem<MenuAction>(
                value: MenuAction.sortByDateOldest,
                child: Row(
                  children: [
                    Icon(Icons.sort, size: 20),
                    SizedBox(width: 8),
                    Text('Oldest First'),
                  ],
                ),
              ),
              const PopupMenuItem<MenuAction>(
                value: MenuAction.sortByTitle,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 20),
                    SizedBox(width: 8),
                    Text('Sort by Title'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<MenuAction>(
                value: MenuAction.selectDate,
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20),
                    SizedBox(width: 8),
                    Text('Select Date'),
                  ],
                ),
              ),
              const PopupMenuItem<MenuAction>(
                value: MenuAction.settings,
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
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
                  prefixIcon: ShowSVG(
                    svgPath: IconAssets.search,
                    height: 20,
                    width: 20,
                  ),
                  contentPadding: EdgeInsets.all(UIHelpers.scaffoldPadding),
                ),
              ),
            ),
          ),
          const Gap(UIHelpers.md),
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
              builder: (context) => CreateEditNoteScreen(note: Note.empty()),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
