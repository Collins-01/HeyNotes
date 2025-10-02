import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hey_notes/core/theme/app_colors.dart';

// ==================== FILE: lib/models/text_style_model.dart ====================
class TextStyleModel {
  bool bold;
  bool italic;
  bool underline;
  Color? backgroundColor;
  Color textColor;
  double fontSize;

  TextStyleModel({
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.backgroundColor,
    this.textColor = Colors.black87,
    this.fontSize = 16.0,
  });

  TextStyleModel copyWith({
    bool? bold,
    bool? italic,
    bool? underline,
    Color? backgroundColor,
    bool clearBackground = false,
    Color? textColor,
    double? fontSize,
  }) {
    return TextStyleModel(
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      backgroundColor: clearBackground
          ? null
          : (backgroundColor ?? this.backgroundColor),
      textColor: textColor ?? this.textColor,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

class FormattingToolbar extends StatelessWidget {
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final double fontSize;
  final bool showColorPicker;
  final VoidCallback onToggleBold;
  final VoidCallback onToggleItalic;
  final VoidCallback onToggleUnderline;
  final VoidCallback onIncreaseFontSize;
  final VoidCallback onDecreaseFontSize;
  final VoidCallback onToggleColorPicker;
  final Function(Color?) onBackgroundColorSelected;
  final Function(Color) onTextColorSelected;

  const FormattingToolbar({
    Key? key,
    required this.isBold,
    required this.isItalic,
    required this.isUnderline,
    required this.fontSize,
    required this.showColorPicker,
    required this.onToggleBold,
    required this.onToggleItalic,
    required this.onToggleUnderline,
    required this.onIncreaseFontSize,
    required this.onDecreaseFontSize,
    required this.onToggleColorPicker,
    required this.onBackgroundColorSelected,
    required this.onTextColorSelected,
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
      child: Column(
        children: [
          Row(
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
                icon: Icons.text_decrease,
                onPressed: onDecreaseFontSize,
              ),
              Text(
                '${fontSize.toInt()}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              _ToolbarIconButton(
                icon: Icons.text_increase,
                onPressed: onIncreaseFontSize,
              ),
              const SizedBox(width: 8),
              _ToolbarIconButton(
                icon: Icons.format_color_fill,
                onPressed: onToggleColorPicker,
              ),
              const Spacer(),
              Text(
                'Select text to format',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
          if (showColorPicker)
            ColorPickerPanel(
              onBackgroundColorSelected: onBackgroundColorSelected,
              onTextColorSelected: onTextColorSelected,
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
  final VoidCallback onPressed;

  const _ToolbarIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.grey[300], size: 20),
        ),
      ),
    );
  }
}

class ColorPickerPanel extends StatelessWidget {
  final Function(Color?) onBackgroundColorSelected;
  final Function(Color) onTextColorSelected;

  const ColorPickerPanel({
    Key? key,
    required this.onBackgroundColorSelected,
    required this.onTextColorSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Background:',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: [
              _ColorButton(
                color: null,
                label: 'None',
                onTap: () => onBackgroundColorSelected(null),
              ),
              _ColorButton(
                color: Colors.yellow[200]!,
                onTap: () => onBackgroundColorSelected(Colors.yellow[200]!),
              ),
              _ColorButton(
                color: Colors.amber[200]!,
                onTap: () => onBackgroundColorSelected(Colors.amber[200]!),
              ),
              _ColorButton(
                color: Colors.green[200]!,
                onTap: () => onBackgroundColorSelected(Colors.green[200]!),
              ),
              _ColorButton(
                color: Colors.blue[200]!,
                onTap: () => onBackgroundColorSelected(Colors.blue[200]!),
              ),
              _ColorButton(
                color: Colors.pink[200]!,
                onTap: () => onBackgroundColorSelected(Colors.pink[200]!),
              ),
              _ColorButton(
                color: Colors.purple[200]!,
                onTap: () => onBackgroundColorSelected(Colors.purple[200]!),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Text Color:',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: [
              _ColorButton(
                color: Colors.black87,
                onTap: () => onTextColorSelected(Colors.black87),
              ),
              _ColorButton(
                color: Colors.red,
                onTap: () => onTextColorSelected(Colors.red),
              ),
              _ColorButton(
                color: Colors.blue,
                onTap: () => onTextColorSelected(Colors.blue),
              ),
              _ColorButton(
                color: Colors.green[700]!,
                onTap: () => onTextColorSelected(Colors.green[700]!),
              ),
              _ColorButton(
                color: Colors.purple,
                onTap: () => onTextColorSelected(Colors.purple),
              ),
              _ColorButton(
                color: Colors.orange,
                onTap: () => onTextColorSelected(Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color? color;
  final String? label;
  final VoidCallback onTap;

  const _ColorButton({required this.color, this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          border: Border.all(
            color: Colors.grey[600]!,
            width: color == null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: label != null
            ? Center(
                child: Text(
                  label!,
                  style: const TextStyle(fontSize: 10, color: Colors.black),
                ),
              )
            : null,
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
  bool _showColorPicker = false;

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

  void _changeFontSize(double delta) {
    _applyFormatting(
      (style) =>
          style.copyWith(fontSize: (style.fontSize + delta).clamp(10.0, 40.0)),
    );
  }

  void _applyBackgroundColor(Color? color) {
    _applyFormatting(
      (style) => style.copyWith(
        backgroundColor: color,
        clearBackground: color == null,
      ),
    );
    setState(() => _showColorPicker = false);
  }

  void _applyTextColor(Color color) {
    _applyFormatting((style) => style.copyWith(textColor: color));
  }

  List<TextSpan> _buildTextSpans() {
    if (_controller.text.isEmpty) return [const TextSpan(text: '')];

    final spans = <TextSpan>[];
    TextStyleModel? currentStyle;
    String currentText = '';

    for (int i = 0; i < _controller.text.length; i++) {
      final charStyle = _formatting[i] ?? TextStyleModel();

      if (currentStyle == null ||
          currentStyle.bold != charStyle.bold ||
          currentStyle.italic != charStyle.italic ||
          currentStyle.underline != charStyle.underline ||
          currentStyle.backgroundColor != charStyle.backgroundColor ||
          currentStyle.textColor != charStyle.textColor ||
          currentStyle.fontSize != charStyle.fontSize) {
        if (currentText.isNotEmpty && currentStyle != null) {
          spans.add(
            TextSpan(
              text: currentText,
              style: TextStyle(
                fontWeight: currentStyle.bold
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontStyle: currentStyle.italic
                    ? FontStyle.italic
                    : FontStyle.normal,
                decoration: currentStyle.underline
                    ? TextDecoration.underline
                    : TextDecoration.none,
                backgroundColor: currentStyle.backgroundColor,
                color: currentStyle.textColor,
                fontSize: currentStyle.fontSize,
                height: 1.5,
              ),
            ),
          );
        }

        currentText = _controller.text[i];
        currentStyle = charStyle;
      } else {
        currentText += _controller.text[i];
      }
    }

    if (currentText.isNotEmpty && currentStyle != null) {
      spans.add(
        TextSpan(
          text: currentText,
          style: TextStyle(
            fontWeight: currentStyle.bold ? FontWeight.bold : FontWeight.normal,
            fontStyle: currentStyle.italic
                ? FontStyle.italic
                : FontStyle.normal,
            decoration: currentStyle.underline
                ? TextDecoration.underline
                : TextDecoration.none,
            backgroundColor: currentStyle.backgroundColor,
            color: currentStyle.textColor,
            fontSize: currentStyle.fontSize,
            height: 1.5,
          ),
        ),
      );
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormattingToolbar(
          isBold: _currentStyle.bold,
          isItalic: _currentStyle.italic,
          isUnderline: _currentStyle.underline,
          fontSize: _currentStyle.fontSize,
          showColorPicker: _showColorPicker,
          onToggleBold: _toggleBold,
          onToggleItalic: _toggleItalic,
          onToggleUnderline: _toggleUnderline,
          onIncreaseFontSize: () => _changeFontSize(2),
          onDecreaseFontSize: () => _changeFontSize(-2),
          onToggleColorPicker: () =>
              setState(() => _showColorPicker = !_showColorPicker),
          onBackgroundColorSelected: _applyBackgroundColor,
          onTextColorSelected: _applyTextColor,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: SelectableText.rich(
                    TextSpan(children: _buildTextSpans()),
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
