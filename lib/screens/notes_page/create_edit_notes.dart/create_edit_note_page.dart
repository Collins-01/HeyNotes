import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/core/theme/app_colors.dart' show AppColors;
import 'package:hey_notes/core/utils/ui_helpers.dart';
import 'package:hey_notes/models/note.dart';
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
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(createEditNotesViewModel.notifier).onInt(widget.note);
      _controller.document.insert(0, widget.note?.content ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(createEditNotesViewModel.notifier);
    final state = ref.watch(createEditNotesViewModel);
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
              FocusScope.of(context).unfocus();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => CategorySelectionSheet(
                  selectedCategoryID: state.note?.categoryId,
                  onSave: (category) {
                    vm.setCategoryID(category?.name);
                    vm.saveNote(
                      context,
                      controller: _controller,
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
            visible: state.note != null,
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
                  if (state.note != null) {
                    await vm.exportAndShareAsPdf(state.note!);
                  }
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
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // Makes the whole area tappable

        onTap: () {
          // Unfocus when tapping outside
          _focusNode?.unfocus();
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: quill.QuillEditor.basic(
            config: const quill.QuillEditorConfig(
              autoFocus: true,
              textInputAction: TextInputAction.done,
              scrollable: true,
            ),
            controller: _controller,
            focusNode: _focusNode,
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: UIHelpers.scaffoldPadding,
          right: UIHelpers.scaffoldPadding,
        ),
        child: Container(
          height: 55,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UIHelpers.borderRadiusLg),
            color: AppColors.textBlack,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _customToolbarButton(
                  icon: Icons.format_bold,
                  onPressed: () => _toggleAttribute(quill.Attribute.bold),
                  isToggled: _isAttributeActive(quill.Attribute.bold),
                ),
                _customToolbarButton(
                  icon: Icons.format_italic,
                  onPressed: () => _toggleAttribute(quill.Attribute.italic),
                  isToggled: _isAttributeActive(quill.Attribute.italic),
                ),
                _customToolbarButton(
                  icon: Icons.format_underline,
                  onPressed: () => _toggleAttribute(quill.Attribute.underline),
                  isToggled: _isAttributeActive(quill.Attribute.underline),
                ),
                _customToolbarButton(
                  icon: Icons.format_align_left,
                  onPressed: () =>
                      _toggleAttribute(quill.Attribute.leftAlignment),
                  isToggled: _isAttributeActive(quill.Attribute.leftAlignment),
                ),
                _customToolbarButton(
                  icon: Icons.format_align_center,
                  onPressed: () =>
                      _toggleAttribute(quill.Attribute.centerAlignment),
                  isToggled: _isAttributeActive(
                    quill.Attribute.centerAlignment,
                  ),
                ),
                _customToolbarButton(
                  icon: Icons.format_align_right,
                  onPressed: () =>
                      _toggleAttribute(quill.Attribute.rightAlignment),
                  isToggled: _isAttributeActive(quill.Attribute.rightAlignment),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customToolbarButton({
    required IconData icon,
    String? label,
    required VoidCallback onPressed,
    bool isToggled = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isToggled ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isToggled ? Colors.blue : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isToggled ? AppColors.info : AppColors.white,
            ),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isToggled ? AppColors.info : AppColors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _toggleAttribute(quill.Attribute attribute) {
    final selection = _controller.selection;
    if (selection.isCollapsed) {
      // Toggle for future input
      _controller.formatSelection(attribute);
    } else {
      // Toggle for selected text
      final currentValue = _controller
          .getSelectionStyle()
          .attributes[attribute.key];

      if (currentValue == null) {
        _controller.formatSelection(attribute);
      } else {
        _controller.formatSelection(quill.Attribute.clone(attribute, null));
      }
    }
    setState(() {});
  }

  bool _isAttributeActive(quill.Attribute attribute) {
    final style = _controller.getSelectionStyle();
    return style.attributes.containsKey(attribute.key);
  }
}
