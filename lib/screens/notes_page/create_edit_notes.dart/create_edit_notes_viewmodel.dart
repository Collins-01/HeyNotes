import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/core/services/pdf_service.dart';
import 'package:hey_notes/core/theme/app_colors.dart';
import 'package:hey_notes/core/utils/logger.dart';
import 'package:hey_notes/extension/extension.dart';
import 'package:hey_notes/models/note.dart';
import 'package:hey_notes/models/option.dart';
import 'package:hey_notes/providers/note_provider.dart';
import 'package:hey_notes/screens/home/homepage/homepage_viewmodel.dart';
import 'package:hey_notes/screens/notes_page/create_edit_notes.dart/create_edit_note_state.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:share_plus/share_plus.dart';
import 'package:swift_alert/swift_alert.dart';
import 'package:uuid/uuid.dart';

class CreateEditNotesViewmodel extends StateNotifier<CreateEditNoteState> {
  final Ref ref;
  CreateEditNotesViewmodel(this.ref) : super(CreateEditNoteState.initial());

  void onInt(Note? note) {
    AppLogger.d('Incoming Note: ${note.toString()}');
    state = state.copyWith(note: note);
    state = state.copyWith(isPinned: note?.isPinned ?? false);
    state = state.copyWith(categoryID: Optional.of(note?.categoryId));
  }

  void updateTitle(String title) {
    if (state.note != null) {
      state = state.copyWith(
        note: state.note!.copyWith(title: title, updatedAt: DateTime.now()),
      );
    } else {
      // Create a new note with the title if one doesn't exist yet
      state = state.copyWith(
        note: Note(
          id: const Uuid().v4(),
          title: title,
          content: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isPinned: false,
          color: AppColors.getRandomNoteColor().toHexCode(),
        ),
      );
    }
  }

  void setCategoryID(String? categoryID) {
    AppLogger.d('Setting Category ID to : $categoryID');
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
      shareContent.writeln(note.getPlainText());
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

    if (note.getPlainText().isNotEmpty) {
      content.writeln(note.getPlainText());
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
    final pdfFile = await PdfExportService.exportMultipleNotesToPdf(
      [note],
      filename:
          'my_notes_${note.title}_${DateTime.now().millisecondsSinceEpoch}',
    );
    await PdfExportService.sharePdf(pdfFile);
  }

  void saveNote(
    BuildContext context, {
    required QuillController controller,
    VoidCallback? callback,
    required String title,
    required bool isEdit,
  }) {
    try {
      // Convert Quill content to string

      final content = Note.quillToString(controller);

      if (isEdit) {
        AppLogger.d('Editing note: ${state.note!.id}');
        ref
            .read(noteProvider.notifier)
            .updateNote(
              Note(
                id: state.note!.id,
                title: title,
                content: content,
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
        ref.read(homepageViewModelProvider.notifier).loadNotes();
        callback?.call();
        return;
      }
      AppLogger.d('Adding new note......');

      final note = Note(
        id: const Uuid().v4(),
        title: title,
        content: Note.quillToString(controller),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPinned: state.isPinned,
        color: AppColors.getRandomNoteColor().toHexCode(),
        categoryId: state.categoryID.valueOrNull,
        tags: [],
      );
      AppLogger.d('New note added: ${note.id}');

      ref.read(noteProvider.notifier).addNote(note);
      SwiftAlert.display(
        context,
        message: 'Note saved successfully',
        type: NotificationType.success,
      );
      ref.read(homepageViewModelProvider.notifier).loadNotes();
      callback?.call();
    } catch (e) {
      AppLogger.e(e.toString());
      SwiftAlert.display(
        context,
        message: 'Failed to save note',
        type: NotificationType.error,
      );
      return;
    }
  }
}

final createEditNotesViewModel =
    StateNotifierProvider<CreateEditNotesViewmodel, CreateEditNoteState>((ref) {
      return CreateEditNotesViewmodel(ref);
    });
