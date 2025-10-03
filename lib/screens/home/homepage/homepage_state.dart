import 'package:equatable/equatable.dart';
import 'package:hey_notes/enums/note_sort.dart';
import 'package:hey_notes/models/note.dart';

class HomepageState extends Equatable {
  final bool isLoading;
  final String? selectedCategoryID;
  final DateTime selectedDate;
  final List<Note> notes;
  final NoteSort sortOrder;
  
  const HomepageState({
    this.isLoading = false,
    this.selectedCategoryID,
    required this.selectedDate,
    this.notes = const [],
    this.sortOrder = NoteSort.newestFirst,
  });

  HomepageState.initial() : this(selectedDate: DateTime.now());

  HomepageState copyWith({
    bool? isLoading,
    String? selectedCategoryID,
    DateTime? selectedDate,
    List<Note>? notes,
    NoteSort? sortOrder,
  }) {
    return HomepageState(
      isLoading: isLoading ?? this.isLoading,
      selectedCategoryID: selectedCategoryID ?? this.selectedCategoryID,
      selectedDate: selectedDate ?? this.selectedDate,
      notes: notes ?? this.notes,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    selectedCategoryID,
    selectedDate,
    notes,
    sortOrder,
  ];
}
