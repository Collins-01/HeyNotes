import 'package:equatable/equatable.dart';
import 'package:hey_notes/models/note.dart';

class CreateEditNoteState extends Equatable {
  final Note? note;
  final bool isPinned;

  const CreateEditNoteState({this.isPinned = false, this.note});

  CreateEditNoteState copyWith({Note? note, bool? isPinned}) {
    return CreateEditNoteState(
      isPinned: isPinned ?? this.isPinned,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [note, isPinned];
}
