import 'package:flutter/material.dart';
import 'package:hey_notes/core/theme/app_colors.dart';

// ==================== FILE: lib/models/text_style_model.dart ====================
enum TextAlignment { left, center, right, justify }

class TextStyleModel {
  bool bold;
  bool italic;
  bool underline;
  TextAlignment alignment;

  TextStyleModel({
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.alignment = TextAlignment.left,
  });

  TextStyleModel copyWith({
    bool? bold,
    bool? italic,
    bool? underline,
    TextAlignment? alignment,
  }) {
    return TextStyleModel(
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      alignment: alignment ?? this.alignment,
    );
  }
}

class FormattingToolbar extends StatelessWidget {
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final TextAlignment alignment;
  final VoidCallback onToggleBold;
  final VoidCallback onToggleItalic;
  final VoidCallback onToggleUnderline;
  final Function(TextAlignment) onAlignmentChanged;

  const FormattingToolbar({
    Key? key,
    required this.isBold,
    required this.isItalic,
    required this.isUnderline,
    required this.alignment,
    required this.onToggleBold,
    required this.onToggleItalic,
    required this.onToggleUnderline,
    required this.onAlignmentChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _ToolbarButton(
            label: 'B',
            isActive: isBold,
            onPressed: onToggleBold,
          ),
          _ToolbarButton(
            label: 'I',
            isActive: isItalic,
            onPressed: onToggleItalic,
          ),
          _ToolbarButton(
            label: 'U',
            isActive: isUnderline,
            onPressed: onToggleUnderline,
          ),
          const SizedBox(width: 8),
          _ToolbarIconButton(
            icon: Icons.format_align_left,
            isActive: alignment == TextAlignment.left,
            onPressed: () => onAlignmentChanged(TextAlignment.left),
          ),
          _ToolbarIconButton(
            icon: Icons.format_align_center,
            isActive: alignment == TextAlignment.center,
            onPressed: () => onAlignmentChanged(TextAlignment.center),
          ),
          _ToolbarIconButton(
            icon: Icons.format_align_right,
            isActive: alignment == TextAlignment.right,
            onPressed: () => onAlignmentChanged(TextAlignment.right),
          ),
          _ToolbarIconButton(
            icon: Icons.format_align_justify,
            isActive: alignment == TextAlignment.justify,
            onPressed: () => onAlignmentChanged(TextAlignment.justify),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? Colors.blue : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[300],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;

  const _ToolbarIconButton({
    required this.icon,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? Colors.blue : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, 
            color: isActive ? Colors.white : Colors.grey[300], 
            size: 20
          ),
        ),
      ),
    );
  }
}

// ==================== FILE: lib/widgets/rich_text_editor.dart ====================

class RichTextEditor extends StatefulWidget {
  final String initialText;
  final VoidCallback? onSave;

  const RichTextEditor({super.key, this.initialText = '', this.onSave});

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  Map<int, TextStyleModel> _formatting = {};
  TextStyleModel _currentStyle = TextStyleModel();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);

    for (int i = 0; i < _controller.text.length; i++) {
      _formatting[i] = TextStyleModel();
    }

    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _controller.text;
    final oldLength = _formatting.length;

    if (text.length > oldLength) {
      for (int i = oldLength; i < text.length; i++) {
        _formatting[i] = _currentStyle.copyWith();
      }
    } else if (text.length < oldLength) {
      final newFormatting = <int, TextStyleModel>{};
      for (int i = 0; i < text.length; i++) {
        newFormatting[i] = _formatting[i] ?? TextStyleModel();
      }
      _formatting = newFormatting;
    }
    setState(() {});
  }

  void _applyFormatting(TextStyleModel Function(TextStyleModel) modifier) {
    final selection = _controller.selection;

    if (!selection.isValid || selection.start == selection.end) {
      setState(() {
        _currentStyle = modifier(_currentStyle);
      });
      return;
    }

    setState(() {
      for (int i = selection.start; i < selection.end; i++) {
        _formatting[i] = modifier(_formatting[i] ?? TextStyleModel());
      }
    });
  }

  void _toggleBold() {
    _applyFormatting((style) => style.copyWith(bold: !style.bold));
  }

  void _toggleItalic() {
    _applyFormatting((style) => style.copyWith(italic: !style.italic));
  }

  void _toggleUnderline() {
    _applyFormatting((style) => style.copyWith(underline: !style.underline));
  }

  void _changeAlignment(TextAlignment alignment) {
    _applyFormatting((style) => style.copyWith(alignment: alignment));
  }

  List<TextSpan> _buildTextSpans() {
    if (_controller.text.isEmpty) return [const TextSpan(text: '')];

    final spans = <TextSpan>[];
    TextStyleModel? currentStyle;
    String currentText = '';
    TextAlign currentAlignment = TextAlign.left;

    for (int i = 0; i < _controller.text.length; i++) {
      final charStyle = _formatting[i] ?? TextStyleModel();

      // Handle alignment changes (only at the start of a new line)
      if (i == 0 || _controller.text[i - 1] == '\n') {
        final newAlignment = _getTextAlignForStyle(charStyle);
        if (newAlignment != currentAlignment) {
          currentAlignment = newAlignment;
          // Close previous span if exists
          if (currentText.isNotEmpty && currentStyle != null) {
            spans.add(_createTextSpan(currentText, currentStyle));
            currentText = '';
          }
        }
      }

      if (currentStyle == null ||
          currentStyle.bold != charStyle.bold ||
          currentStyle.italic != charStyle.italic ||
          currentStyle.underline != charStyle.underline) {
        if (currentText.isNotEmpty && currentStyle != null) {
          spans.add(_createTextSpan(currentText, currentStyle));
        }
        currentText = _controller.text[i];
        currentStyle = charStyle;
      } else {
        currentText += _controller.text[i];
      }
    }

    if (currentText.isNotEmpty && currentStyle != null) {
      spans.add(_createTextSpan(currentText, currentStyle));
    }

    return spans;
  }

  TextSpan _createTextSpan(String text, TextStyleModel style) {
    return TextSpan(
      text: text,
      style: TextStyle(
        fontWeight: style.bold ? FontWeight.bold : FontWeight.normal,
        fontStyle: style.italic ? FontStyle.italic : FontStyle.normal,
        decoration: style.underline ? TextDecoration.underline : TextDecoration.none,
        height: 1.5,
      ),
    );
  }

  TextAlign _getTextAlignForStyle(TextStyleModel style) {
    switch (style.alignment) {
      case TextAlignment.left:
        return TextAlign.left;
      case TextAlignment.center:
        return TextAlign.center;
      case TextAlignment.right:
        return TextAlign.right;
      case TextAlignment.justify:
        return TextAlign.justify;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormattingToolbar(
          isBold: _currentStyle.bold,
          isItalic: _currentStyle.italic,
          isUnderline: _currentStyle.underline,
          alignment: _currentStyle.alignment,
          onToggleBold: _toggleBold,
          onToggleItalic: _toggleItalic,
          onToggleUnderline: _toggleUnderline,
          onAlignmentChanged: _changeAlignment,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: SelectableText.rich(
                    TextSpan(children: _buildTextSpans()),
                    textAlign: _getTextAlignForStyle(_currentStyle),
                    onSelectionChanged: (selection, cause) {
                      if (selection.start != selection.end) {
                        final firstCharStyle =
                            _formatting[selection.start] ?? TextStyleModel();
                        setState(() {
                          _currentStyle = firstCharStyle;
                        });
                      }
                    },
                  ),
                ),
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  textAlign: _getTextAlignForStyle(_currentStyle),
                  style: const TextStyle(color: Colors.transparent),
                  decoration: const InputDecoration(border: InputBorder.none),
                  cursorColor: AppColors.info,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
