import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/extension/extension.dart';
import 'package:hey_notes/models/note.dart';
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
  CreateEditNotesViewmodel(this.ref) : super(const CreateEditNoteState());

  onInt(bool value) {
    state = state.copyWith(isPinned: value);
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

  Future<File> exportAsPdf(Note note) async {
    final pdf = pw.Document();
    final font = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(font);
    final boldTtf = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (note.title.isNotEmpty) ...[
                pw.Text(
                  note.title,
                  style: pw.TextStyle(font: boldTtf, fontSize: 24),
                ),
                pw.SizedBox(height: 10),
              ],
              if (note.content.isNotEmpty) ...[
                pw.Text(
                  note.content,
                  style: pw.TextStyle(font: ttf, fontSize: 12),
                ),
                pw.SizedBox(height: 10),
              ],
              if (note.tags.isNotEmpty) ...[
                pw.Text(
                  'Tags: ${note.tags.join(', ')}',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
                pw.SizedBox(height: 10),
              ],
              pw.Text(
                'Last updated: ${DateFormat('dd MMM yyyy').format(note.updatedAt)}',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 10,
                  color: const PdfColor.fromInt(0xFF666666),
                ),
              ),
            ],
          );
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/${note.title.isEmpty ? 'note' : note.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> exportAndShareAsPdf(BuildContext context, Note note) async {
    try {
      final file = await exportAsPdf(note);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Note: ${note.title.isNotEmpty ? note.title : 'Untitled'}',
        text: 'Here\'s your exported note as PDF',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export note as PDF')),
        );
      }
    }
  }

  void saveNote(
    BuildContext context, {
    required String content,
    String? categoryID,
    VoidCallback? callback,
  }) {
    bool isEdit = state.note != null;
    if (isEdit) {
      ref
          .read(noteProvider.notifier)
          .updateNote(
            Note(
              id: state.note!.id,
              title: content.generateTitle,
              content: content,
              createdAt: state.note!.createdAt,
              updatedAt: DateTime.now(),
              isPinned: state.isPinned,
              categoryId: state.note!.categoryId,
              tags: state.note!.tags,
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
      title: content.generateTitle,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPinned: state.isPinned,
      categoryId: categoryID,
      tags: state.note!.tags,
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
