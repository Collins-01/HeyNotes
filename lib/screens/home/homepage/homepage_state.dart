import 'package:equatable/equatable.dart';
import 'package:hey_notes/models/note.dart';

class HomepageState extends Equatable {
  final bool isLoading;
  final String? selectedCategoryID;
  final DateTime selectedDate;
  final List<Note> notes;
  const HomepageState({
    this.isLoading = false,
    this.selectedCategoryID,
    required this.selectedDate,
    this.notes = const [],
  });

  HomepageState.initial() : this(selectedDate: DateTime.now());

  HomepageState copyWith({
    bool? isLoading,
    String? selectedCategoryID,
    DateTime? selectedDate,
    List<Note>? notes,
  }) {
    return HomepageState(
      isLoading: isLoading ?? this.isLoading,
      selectedCategoryID: selectedCategoryID ?? this.selectedCategoryID,
      selectedDate: selectedDate ?? this.selectedDate,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    selectedCategoryID,
    selectedDate,
    notes,
  ];
}
