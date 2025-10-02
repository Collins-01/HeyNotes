import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/note.dart';
import '../../providers/note_provider.dart';
import 'create_edit_notes.dart/note_edit_screen.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

enum ShareOption { text, textFile, pdf }

class ShareOptionsBottomSheet extends StatelessWidget {
  const ShareOptionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Share as Text'),
            onTap: () => Navigator.pop(context, ShareOption.text),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: const Text('Export as Text File'),
            onTap: () => Navigator.pop(context, ShareOption.textFile),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Export as PDF'),
            onTap: () => Navigator.pop(context, ShareOption.pdf),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class NoteViewScreen extends ConsumerStatefulWidget {
  final Note note;

  const NoteViewScreen({super.key, required this.note});

  @override
  ConsumerState<NoteViewScreen> createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends ConsumerState<NoteViewScreen> {
  final quill.QuillController _controller = quill.QuillController.basic();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.document.insert(0, widget.note.content);
    });
  }

  Future<void> _deleteNote(BuildContext context, WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text(
          'Are you sure you want to delete this note? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      try {
        await ref.read(noteProvider.notifier).deleteNote(widget.note.id);
        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete note: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _navigateToEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(note: widget.note),
      ),
    );
  }

  Future<void> _shareNote(BuildContext context) async {
    final result = await showModalBottomSheet<ShareOption>(
      context: context,
      builder: (context) => const ShareOptionsBottomSheet(),
    );

    if (result == null) return;

    switch (result) {
      case ShareOption.text:
        await _shareAsText();
        break;
      case ShareOption.textFile:
        await _exportAndShareAsTextFile(context);
        break;
      case ShareOption.pdf:
        await _exportAndShareAsPdf(context);
        break;
    }
  }

  Future<void> _shareAsText() async {
    final StringBuffer shareContent = StringBuffer();

    // Add title if exists
    if (widget.note.title.isNotEmpty) {
      shareContent.writeln(widget.note.title);
      shareContent.writeln(
        '${'─' * (widget.note.title.length > 30 ? 30 : widget.note.title.length)}\n',
      );
    }

    // Add content
    if (widget.note.content.isNotEmpty) {
      shareContent.writeln(widget.note.content);
    }

    // Add tags if they exist
    if (widget.note.tags.isNotEmpty) {
      shareContent.writeln('\nTags: ${widget.note.tags.join(', ')}');
    }

    // Add last updated date
    shareContent.writeln(
      '\nLast updated: ${DateFormat('dd MMM yyyy').format(widget.note.updatedAt)}',
    );

    await Share.share(shareContent.toString());
  }

  Future<File> _exportAsTextFile() async {
    final StringBuffer content = StringBuffer();

    if (widget.note.title.isNotEmpty) {
      content.writeln(widget.note.title);
      content.writeln(
        '${'─' * (widget.note.title.length > 30 ? 30 : widget.note.title.length)}\n',
      );
    }

    if (widget.note.content.isNotEmpty) {
      content.writeln(widget.note.content);
    }

    if (widget.note.tags.isNotEmpty) {
      content.writeln('\nTags: ${widget.note.tags.join(', ')}');
    }

    content.writeln(
      '\nLast updated: ${DateFormat('dd MMM yyyy').format(widget.note.updatedAt)}',
    );

    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/${widget.note.title.isEmpty ? 'note' : widget.note.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.txt',
    );

    await file.writeAsString(content.toString());
    return file;
  }

  Future<void> _exportAndShareAsTextFile(BuildContext context) async {
    try {
      final file = await _exportAsTextFile();
      await Share.shareXFiles(
        [XFile(file.path)],
        subject:
            'Note: ${widget.note.title.isNotEmpty ? widget.note.title : 'Untitled'}',
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

  Future<File> _exportAsPdf() async {
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
              if (widget.note.title.isNotEmpty) ...[
                pw.Text(
                  widget.note.title,
                  style: pw.TextStyle(font: boldTtf, fontSize: 24),
                ),
                pw.SizedBox(height: 10),
              ],
              if (widget.note.content.isNotEmpty) ...[
                pw.Text(
                  widget.note.content,
                  style: pw.TextStyle(font: ttf, fontSize: 12),
                ),
                pw.SizedBox(height: 10),
              ],
              if (widget.note.tags.isNotEmpty) ...[
                pw.Text(
                  'Tags: ${widget.note.tags.join(', ')}',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
                pw.SizedBox(height: 10),
              ],
              pw.Text(
                'Last updated: ${DateFormat('dd MMM yyyy').format(widget.note.updatedAt)}',
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
      '${directory.path}/${widget.note.title.isEmpty ? 'note' : widget.note.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> _exportAndShareAsPdf(BuildContext context) async {
    try {
      final file = await _exportAsPdf();
      await Share.shareXFiles(
        [XFile(file.path)],
        subject:
            'Note: ${widget.note.title.isNotEmpty ? widget.note.title : 'Untitled'}',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Note'),
        actions: [
          PopupMenuButton<ShareOption>(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onSelected: (option) async {
              switch (option) {
                case ShareOption.text:
                  await _shareAsText();
                  break;
                case ShareOption.textFile:
                  await _exportAndShareAsTextFile(context);
                  break;
                case ShareOption.pdf:
                  await _exportAndShareAsPdf(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ShareOption.text,
                child: Text('Share as Text'),
              ),
              const PopupMenuItem(
                value: ShareOption.textFile,
                child: Text('Export as Text File'),
              ),
              const PopupMenuItem(
                value: ShareOption.pdf,
                child: Text('Export as PDF'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _navigateToEditScreen(context),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteNote(context, ref),
            tooltip: 'Delete',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            quill.QuillEditor(
              controller: _controller,
              scrollController: ScrollController(),
              // scrollable: true,
              focusNode: FocusNode(),

              // autoFocus: true,
              // readOnly: false,
              // expands: false,
              // padding: EdgeInsets.all(10),
              // customStyles: quill.DefaultStyles(
              //   paragraphStyle: TextStyle(fontSize: 16),
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
