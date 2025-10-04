import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/core/services/pdf_service.dart';
import 'package:hey_notes/core/theme/app_colors.dart';
import 'package:hey_notes/extension/extension.dart';
import 'package:hey_notes/models/note.dart';
import 'package:hey_notes/models/option.dart';
import 'package:hey_notes/providers/note_provider.dart';
import 'package:hey_notes/screens/notes_page/create_edit_notes.dart/create_edit_note_state.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:swift_alert/swift_alert.dart';
import 'package:uuid/uuid.dart';

class CreateEditNotesViewmodel extends StateNotifier<CreateEditNoteState> {
  final Ref ref;
  CreateEditNotesViewmodel(this.ref) : super(CreateEditNoteState.initial());

  void onInt(Note? note) {
    state = state.copyWith(note: note);
    state = state.copyWith(isPinned: note?.isPinned ?? false);
    state = state.copyWith(categoryID: Optional.of(note?.categoryId));
  }

  void setCategoryID(String? categoryID) {
    state = state.copyWith(categoryID: Optional.of(categoryID));
  }

  void toggleIsPinned() {
    bool isPinned = state.isPinned;
    state = state.copyWith(isPinned: !isPinned);
  }

  Future<void> shareAsText(Note note) async {
    final StringBuffer shareContent = StringBuffer();

    // Add title if exists
    if (note.title.isNotEmpty) {
      shareContent.writeln(note.title);
      shareContent.writeln(
        '${'─' * (note.title.length > 30 ? 30 : note.title.length)}\n',
      );
    }

    // Add content
    if (note.content.isNotEmpty) {
      shareContent.writeln(note.content);
    }

    // Add tags if they exist
    if (note.tags.isNotEmpty) {
      shareContent.writeln('\nTags: ${note.tags.join(', ')}');
    }

    // Add last updated date
    shareContent.writeln(
      '\nLast updated: ${DateFormat('dd MMM yyyy').format(note.updatedAt)}',
    );

    await Share.share(shareContent.toString());
  }

  Future<File> exportAsTextFile(Note note) async {
    final StringBuffer content = StringBuffer();

    if (note.title.isNotEmpty) {
      content.writeln(note.title);
      content.writeln(
        '${'─' * (note.title.length > 30 ? 30 : note.title.length)}\n',
      );
    }

    if (note.content.isNotEmpty) {
      content.writeln(note.content);
    }

    if (note.tags.isNotEmpty) {
      content.writeln('\nTags: ${note.tags.join(', ')}');
    }

    content.writeln(
      '\nLast updated: ${DateFormat('dd MMM yyyy').format(note.updatedAt)}',
    );

    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/${note.title.isEmpty ? 'note' : note.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.txt',
    );

    await file.writeAsString(content.toString());
    return file;
  }

  Future<void> exportAndShareAsTextFile(BuildContext context, Note note) async {
    try {
      final file = await exportAsTextFile(note);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Note: ${note.title.isNotEmpty ? note.title : 'Untitled'}',
        text: 'Here\'s your exported note',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export note as text file')),
        );
      }
    }
  }

  Future<void> exportAndShareAsPdf(Note note) async {
    await PdfExportService.exportAndShare(note);
  }

  void saveNote(
    BuildContext context, {
    required QuillController controller,
    VoidCallback? callback,
  }) {
    // Convert Quill content to string
    final content = Note.quillToString(controller);

    // Get plain text for title generation
    final plainText = controller.document.toPlainText().trim();

    bool isEdit = state.note != null;

    if (isEdit) {
      ref
          .read(noteProvider.notifier)
          .updateNote(
            Note(
              id: state.note!.id,
              title: plainText.generateTitle, // Use plain text for title
              content: content, // Store Quill JSON string
              createdAt: state.note!.createdAt,
              updatedAt: DateTime.now(),
              isPinned: state.isPinned,
              categoryId: state.categoryID.valueOrNull,
              tags: state.note!.tags,
              color: state.note!.color,
            ),
          );
      SwiftAlert.display(
        context,
        message: 'Note updated successfully',
        type: NotificationType.success,
      );
      callback?.call();
      return;
    }

    final note = Note(
      id: const Uuid().v4(),
      title: plainText.generateTitle, // Use plain text for title
      content: content, // Store Quill JSON string
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPinned: state.isPinned,
      //#FF9E9E
      color: AppColors.getRandomNoteColor().toHexCode(),
      categoryId: state.categoryID.valueOrNull,
      tags: [],
    );

    ref.read(noteProvider.notifier).addNote(note);
    SwiftAlert.display(
      context,
      message: 'Note saved successfully',
      type: NotificationType.success,
    );
    callback?.call();
  }
}

final createEditNotesViewModel =
    StateNotifierProvider<CreateEditNotesViewmodel, CreateEditNoteState>((ref) {
      return CreateEditNotesViewmodel(ref);
    });
