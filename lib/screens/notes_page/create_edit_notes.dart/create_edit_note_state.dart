import 'package:equatable/equatable.dart';
import 'package:hey_notes/models/note.dart';
import 'package:hey_notes/models/option.dart';

class CreateEditNoteState extends Equatable {
  final Note? note;
  final bool isPinned;
  final Optional<String> categoryID;

  const CreateEditNoteState({
    this.isPinned = false,
    this.note,
    required this.categoryID,
  });

  factory CreateEditNoteState.initial() {
    return CreateEditNoteState(
      isPinned: false,
      note: null,
      categoryID: Optional.empty(),
    );
  }

  CreateEditNoteState copyWith({
    Note? note,
    bool? isPinned,
    Optional<String>? categoryID,
  }) {
    return CreateEditNoteState(
      isPinned: isPinned ?? this.isPinned,
      note: note ?? this.note,
      categoryID: categoryID ?? this.categoryID,
    );
  }

  @override
  List<Object?> get props => [note, isPinned, categoryID];
}
