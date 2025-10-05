import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hey_notes/core/theme/app_colors.dart' show AppColors;
import 'package:hey_notes/core/utils/constants.dart';
import 'package:hey_notes/core/utils/icon_assets.dart';
import 'package:hey_notes/core/utils/ui_helpers.dart';
import 'package:hey_notes/extension/context_extension.dart';
import 'package:hey_notes/models/note.dart';
import 'package:hey_notes/screens/home/homepage/home_screen.dart';
import 'package:hey_notes/screens/home/homepage/homepage_viewmodel.dart';
import 'package:hey_notes/screens/notes_page/create_edit_notes.dart/create_edit_notes_viewmodel.dart';
import 'package:hey_notes/widgets/category_selection_sheet.dart';

import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:hey_notes/widgets/show_svg.dart';
import 'package:swift_alert/swift_alert.dart';

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

  const CreateEditNoteScreen({super.key, this.note});

  @override
  ConsumerState<CreateEditNoteScreen> createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends ConsumerState<CreateEditNoteScreen> {
  late quill.QuillController _controller;
  TextEditingController? _titleController;
  final _focusNode = FocusNode();
  final _titleFocusNode = FocusNode();
  // bool _isExpanded = false;
  bool _isTitleFocused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(createEditNotesViewModel.notifier).onInt(widget.note);
      }
    });

    // Initialize the controller with the note content if it exists
    if (widget.note?.content.isNotEmpty ?? true) {
      try {
        // Parse the content as JSON and create a document from it
        _controller = widget.note!.toQuillController();
      } catch (e) {
        // Fallback to empty document if parsing fails
        _controller = quill.QuillController.basic();
      }
    } else {
      // Start with a basic empty document
      _controller = quill.QuillController.basic();
    }

    _titleController = TextEditingController(text: widget.note?.title);
    _titleFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isTitleFocused = _titleFocusNode.hasFocus;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(createEditNotesViewModel.notifier);
    final state = ref.watch(createEditNotesViewModel);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: context.isDarkMode ? AppColors.black : AppColors.white,
      appBar: AppBar(
        backgroundColor: context.isDarkMode ? AppColors.black : AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const ShowSVG(
              svgPath: IconAssets.save,
              height: 20,
              width: 20,
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              // validate title
              if (_titleController?.text.isEmpty ?? true) {
                SwiftAlert.display(
                  context,
                  message: 'Title is required',
                  type: NotificationType.error,
                );
                return;
              }
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => CategorySelectionSheet(
                  selectedCategoryID: state.note?.categoryId,
                  onSave: (category) {
                    vm.setCategoryID(
                      category?.name ?? Constants.defaultCategory,
                    );
                    vm.saveNote(
                      context,
                      isEdit: widget.note != null,
                      title: _titleController?.text.trim() ?? '',
                      controller: _controller,
                      callback: () {
                        Navigator.pop(context);
                        // Get the HomeScreen's viewmodel and refresh notes
                        final homeVm = ref.read(
                          homepageViewModelProvider.notifier,
                        );
                        homeVm.onInit();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
            tooltip: 'Save',
          ),
          IconButton(
            icon: ShowSVG(
              svgPath: state.isPinned
                  ? IconAssets.pushPinFilled
                  : IconAssets.pushPin,
              color: state.isPinned ? AppColors.info : AppColors.textBlack,
              height: 20,
              width: 20,
            ),
            onPressed: () => vm.toggleIsPinned(),
            tooltip: 'Pinned',
          ),
          const SizedBox(width: 8),

          Visibility(
            visible: widget.note != null,
            child: PopupMenuButton<ShareOption>(
              icon: const ShowSVG(
                svgPath: IconAssets.upload,
                height: 20,
                width: 20,
              ),
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
          _focusNode.unfocus();
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            // Title TextField
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIHelpers.scaffoldPadding,
                vertical: UIHelpers.md,
              ),
              child: TextField(
                focusNode: _titleFocusNode,
                controller: _titleController,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: UIHelpers.md,
                  ),
                  isDense: true,
                ),
                maxLines: 2,
                minLines: 1,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  // Update the note title in the view model
                  ref
                      .read(createEditNotesViewModel.notifier)
                      .updateTitle(value);
                },
              ),
            ),
            // Divider
            const Divider(height: 1, thickness: 1),
            const Gap(UIHelpers.lg),
            // Quill Editor
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIHelpers.scaffoldPadding,
                ),
                child: quill.QuillEditor.basic(
                  config: const quill.QuillEditorConfig(
                    autoFocus: false,
                    textInputAction: TextInputAction.newline,
                    scrollable: true,
                  ),
                  controller: _controller,
                  focusNode: _focusNode,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isTitleFocused
          ? null
          : Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + UIHelpers.lg,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIHelpers.scaffoldPadding,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Clear formatting button (first button)
                      _customToolbarButton(
                        iconWidget: ShowSVG(
                          svgPath: IconAssets.textT,
                          height: 20,
                          width: 20,
                          color: _hasFormatting()
                              ? AppColors.info
                              : Theme.of(context).scaffoldBackgroundColor,
                        ),
                        onPressed: _clearAllFormatting,
                        isToggled: _hasFormatting(),
                      ),
                      _customToolbarButton(
                        icon: Icons.format_bold,
                        onPressed: () => _toggleAttribute(quill.Attribute.bold),
                        isToggled: _isAttributeActive(quill.Attribute.bold),
                      ),
                      _customToolbarButton(
                        icon: Icons.format_italic,
                        onPressed: () =>
                            _toggleAttribute(quill.Attribute.italic),
                        isToggled: _isAttributeActive(quill.Attribute.italic),
                      ),
                      _customToolbarButton(
                        icon: Icons.format_underline,
                        onPressed: () =>
                            _toggleAttribute(quill.Attribute.underline),
                        isToggled: _isAttributeActive(
                          quill.Attribute.underline,
                        ),
                      ),
                      _customToolbarButton(
                        icon: Icons.format_align_left,
                        onPressed: () =>
                            _toggleAlignment(quill.Attribute.leftAlignment),
                        isToggled: _isAttributeActive(
                          quill.Attribute.leftAlignment,
                        ),
                      ),
                      _customToolbarButton(
                        icon: Icons.format_align_center,
                        onPressed: () =>
                            _toggleAlignment(quill.Attribute.centerAlignment),
                        isToggled: _isAttributeActive(
                          quill.Attribute.centerAlignment,
                        ),
                      ),
                      _customToolbarButton(
                        icon: Icons.format_align_right,
                        onPressed: () =>
                            _toggleAlignment(quill.Attribute.rightAlignment),
                        isToggled: _isAttributeActive(
                          quill.Attribute.rightAlignment,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _customToolbarButton({
    IconData? icon,
    String? label,
    required VoidCallback onPressed,
    bool isToggled = false,
    Widget? iconWidget,
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
            iconWidget ??
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

  // Toggle regular attributes (bold, italic, underline)
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

  // Toggle alignment (only one alignment can be active at a time)
  void _toggleAlignment(quill.Attribute attribute) {
    final selection = _controller.selection;
    final currentStyle = _controller.getSelectionStyle();

    // Check if the clicked alignment is already active
    final isCurrentlyActive = currentStyle.attributes.containsKey(
      attribute.key,
    );

    // Clear all alignments first
    final alignmentAttributes = [
      quill.Attribute.leftAlignment,
      quill.Attribute.centerAlignment,
      quill.Attribute.rightAlignment,
      quill.Attribute.justifyAlignment,
    ];

    for (final alignAttr in alignmentAttributes) {
      if (currentStyle.attributes.containsKey(alignAttr.key)) {
        _controller.formatSelection(quill.Attribute.clone(alignAttr, null));
      }
    }

    // If it wasn't active before, apply the new alignment
    // If it was active, leave it cleared (return to default/left)
    if (!isCurrentlyActive) {
      _controller.formatSelection(attribute);
    }

    setState(() {});
  }

  // Clear all formatting
  void _clearAllFormatting() {
    final selection = _controller.selection;
    final currentStyle = _controller.getSelectionStyle();

    // List of all attributes to clear
    List<quill.Attribute> attributesToClear = [
      quill.Attribute.bold,
      quill.Attribute.italic,
      quill.Attribute.underline,
      quill.Attribute.strikeThrough,
      quill.Attribute.link,
      quill.Attribute.color,
      quill.Attribute.background,
      quill.Attribute.h1,
      quill.Attribute.h2,
      quill.Attribute.h3,
      quill.Attribute.ol,
      quill.Attribute.ul,
      quill.Attribute.checked,
      quill.Attribute.codeBlock,
      quill.Attribute.blockQuote,
      quill.Attribute.codeBlock,
      quill.Attribute.indent,
      quill.Attribute.leftAlignment,
      quill.Attribute.centerAlignment,
      quill.Attribute.rightAlignment,
      quill.Attribute.justifyAlignment,
    ];

    // Clear each attribute if it exists
    for (final attribute in attributesToClear) {
      if (currentStyle.attributes.containsKey(attribute.key)) {
        _controller.formatSelection(quill.Attribute.clone(attribute, null));
      }
    }

    setState(() {});
  }

  // Check if any formatting is currently active
  bool _hasFormatting() {
    final style = _controller.getSelectionStyle();
    return style.attributes.isNotEmpty;
  }

  // Check if a specific attribute is active
  bool _isAttributeActive(quill.Attribute attribute) {
    final style = _controller.getSelectionStyle();

    // For alignment attributes, check the actual value
    if (attribute.key == 'align') {
      final currentAlign = style.attributes['align'];
      if (currentAlign == null) {
        // No alignment set means left alignment (default)
        return attribute.value == 'left';
      }
      return currentAlign.value == attribute.value;
    }

    // For other attributes, just check if key exists
    return style.attributes.containsKey(attribute.key);
  }
}
