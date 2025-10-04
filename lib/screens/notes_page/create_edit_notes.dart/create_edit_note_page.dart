import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/models/note.dart';
import 'package:hey_notes/screens/notes_page/components/rich_text_editor.dart';
import 'package:hey_notes/screens/notes_page/create_edit_notes.dart/create_edit_notes_viewmodel.dart';
import 'package:hey_notes/widgets/category_selection_sheet.dart';

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

class CreateEditNoteScreen extends ConsumerStatefulWidget {
  final Note? note;

  const CreateEditNoteScreen({super.key, required this.note});

  @override
  ConsumerState<CreateEditNoteScreen> createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends ConsumerState<CreateEditNoteScreen> {
  final quill.QuillController _controller = quill.QuillController.basic();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(createEditNotesViewModel.notifier)
          .onInt(widget.note?.isPinned ?? false);
      _controller.document.insert(0, widget.note?.content ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(createEditNotesViewModel.notifier);
    final state = ref.watch(createEditNotesViewModel);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => CategorySelectionSheet(
                  selectedCategoryID: state.note?.categoryId,
                  onSave: (category) {
                    vm.saveNote(
                      context,
                      content: _controller.document.toPlainText(),
                      categoryID: category?.name,
                      callback: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              );
            },
            tooltip: 'Save',
          ),
          IconButton(
            icon: state.isPinned
                ? const Icon(Icons.close)
                : const Icon(Icons.push_pin_outlined),
            onPressed: () => vm.toggleIsPinned(),
            tooltip: 'Delete',
          ),
          const SizedBox(width: 8),

          Visibility(
            visible: widget.note != null,
            child: PopupMenuButton<ShareOption>(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share',
              onSelected: (option) async {
                final vm = ref.read(createEditNotesViewModel.notifier);
                if (option == ShareOption.text) {
                  await vm.shareAsText(widget.note!);
                } else if (option == ShareOption.textFile) {
                  await vm.exportAndShareAsTextFile(context, widget.note!);
                } else if (option == ShareOption.pdf) {
                  await vm.exportAndShareAsPdf(context, widget.note!);
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
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RichTextEditor(
          initialText: widget.note?.content ?? '',
          onSave: () {
            // Handle save logic
          },
        ),
        // child: Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     quill.QuillEditor(
        //       controller: _controller,
        //       scrollController: ScrollController(),
        //       // scrollable: true,
        //       focusNode: FocusNode(),

        //       // autoFocus: true,
        //       // readOnly: false,
        //       // expands: false,
        //       // padding: EdgeInsets.all(10),
        //       // customStyles: quill.DefaultStyles(
        //       //   paragraphStyle: TextStyle(fontSize: 16),
        //       // ),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
