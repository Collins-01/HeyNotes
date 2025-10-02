import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/providers/note_provider.dart';
import 'package:hey_notes/screens/home/homepage/homepage_state.dart';

class HomepageViewmodel extends StateNotifier<HomepageState> {
  final Ref ref;
  HomepageViewmodel(this.ref) : super(HomepageState.initial());

  void onInit() async {
    final notes = ref.read(noteProvider);
    state = state.copyWith(notes: notes);
    loadCategories();
  }

  void loadCategories() {}

  void setSelectedCategoryID(String id) {
    state = state.copyWith(selectedCategoryID: id);
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void sortNotes() {}
}

final homepageViewModelProvider =
    StateNotifierProvider<HomepageViewmodel, HomepageState>((ref) {
      return HomepageViewmodel(ref);
    });
