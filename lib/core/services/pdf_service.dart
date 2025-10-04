import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:hey_notes/models/note.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

/// Service for exporting notes to PDF with Quill formatting
class PdfExportService {
  // Font cache to avoid reloading
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;
  static pw.Font? _italicFont;

  /// Initialize fonts (call this once in your app initialization)
  static Future<void> initializeFonts() async {
    final regular = await rootBundle.load('assets/fonts/Avenir Regular.ttf');
    _regularFont = pw.Font.ttf(regular);

    final bold = await rootBundle.load('assets/fonts/Avenir Book.ttf');
    _boldFont = pw.Font.ttf(bold);

    final italic = await rootBundle.load('assets/fonts/Avenir Regular.ttf');
    _italicFont = pw.Font.ttf(italic);
  }

  /// Get or load fonts
  static Future<_FontSet> _getFonts() async {
    if (_regularFont == null || _boldFont == null || _italicFont == null) {
      await initializeFonts();
    }
    return _FontSet(
      regular: _regularFont!,
      bold: _boldFont!,
      italic: _italicFont!,
    );
  }

  /// Export note as PDF and return the file
  static Future<File> exportToPdf(
    Note note, {
    PdfExportOptions? options,
  }) async {
    final opts = options ?? PdfExportOptions();
    final fonts = await _getFonts();
    final pdf = pw.Document();

    // Parse Quill content
    final quillDoc = note.toQuillController().document;
    final pdfContent = _convertQuillToPdfWidgets(quillDoc, fonts, opts);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: opts.pageFormat,
        margin: opts.margin,
        build: (pw.Context context) {
          return [
            // Title
            if (opts.includeTitle && note.title.isNotEmpty) ...[
              pw.Text(
                note.title,
                style: pw.TextStyle(
                  font: fonts.bold,
                  fontSize: opts.titleFontSize,
                ),
              ),
              pw.SizedBox(height: opts.sectionSpacing),
            ],

            // Content with formatting
            ...pdfContent,

            if (opts.includeMetadata) ...[
              pw.SizedBox(height: opts.sectionSpacing),

              // Tags
              if (opts.includeTags && note.tags.isNotEmpty) ...[
                pw.Row(
                  children: [
                    pw.Text(
                      'Tags: ',
                      style: pw.TextStyle(
                        font: fonts.bold,
                        fontSize: opts.metadataFontSize,
                      ),
                    ),
                    ...note.tags.map(
                      (tag) => pw.Container(
                        margin: const pw.EdgeInsets.only(right: 5),
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey300,
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Text(
                          tag,
                          style: pw.TextStyle(
                            font: fonts.regular,
                            fontSize: opts.metadataFontSize - 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
              ],

              // Metadata section
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Created: ${DateFormat('dd MMM yyyy, hh:mm a').format(note.createdAt)}',
                    style: pw.TextStyle(
                      font: fonts.regular,
                      fontSize: opts.metadataFontSize,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    'Updated: ${DateFormat('dd MMM yyyy, hh:mm a').format(note.updatedAt)}',
                    style: pw.TextStyle(
                      font: fonts.regular,
                      fontSize: opts.metadataFontSize,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Word count: ${note.wordCount} | Characters: ${note.characterCount}',
                style: pw.TextStyle(
                  font: fonts.regular,
                  fontSize: opts.metadataFontSize,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ];
        },
      ),
    );

    // Save to file
    final directory = await getTemporaryDirectory();
    final fileName = _sanitizeFileName(
      note.title.isEmpty ? 'note' : note.title,
    );
    final file = File(
      '${directory.path}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Export and share via share sheet
  static Future<void> exportAndShare(
    Note note, {
    PdfExportOptions? options,
    String? customMessage,
  }) async {
    final file = await exportToPdf(note, options: options);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Note: ${note.title.isNotEmpty ? note.title : 'Untitled'}',
      text: customMessage ?? 'Here\'s your exported note as PDF',
    );
  }

  /// Export and save to device storage
  static Future<File> exportAndSave(
    Note note, {
    PdfExportOptions? options,
    String? customPath,
  }) async {
    final file = await exportToPdf(note, options: options);

    // Determine save location
    final Directory saveDir;
    if (customPath != null) {
      saveDir = Directory(customPath);
    } else {
      final baseDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      saveDir = Directory('${baseDir?.path}/Notes');
    }

    // Create directory if it doesn't exist
    await saveDir.create(recursive: true);

    // Copy file to destination
    final fileName = _sanitizeFileName(
      note.title.isEmpty ? 'note' : note.title,
    );
    final savedFile = File('${saveDir.path}/$fileName.pdf');
    await file.copy(savedFile.path);

    return savedFile;
  }

  /// Export multiple notes to a single PDF
  static Future<File> exportMultipleNotes(
    List<Note> notes, {
    String title = 'Notes Export',
    PdfExportOptions? options,
  }) async {
    final opts = options ?? PdfExportOptions();
    final fonts = await _getFonts();
    final pdf = pw.Document();

    for (int i = 0; i < notes.length; i++) {
      final note = notes[i];
      final quillDoc = note.toQuillController().document;
      final pdfContent = _convertQuillToPdfWidgets(quillDoc, fonts, opts);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: opts.pageFormat,
          margin: opts.margin,
          build: (pw.Context context) {
            return [
              // Note title
              pw.Text(
                note.title.isEmpty ? 'Untitled Note ${i + 1}' : note.title,
                style: pw.TextStyle(
                  font: fonts.bold,
                  fontSize: opts.titleFontSize,
                ),
              ),
              pw.SizedBox(height: opts.sectionSpacing),

              // Content
              ...pdfContent,

              // Separator between notes
              if (i < notes.length - 1) ...[
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 20),
              ],
            ];
          },
        ),
      );
    }

    // Save to file
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/${_sanitizeFileName(title)}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ==================== PRIVATE HELPER METHODS ====================

  static List<pw.Widget> _convertQuillToPdfWidgets(
    quill.Document document,
    _FontSet fonts,
    PdfExportOptions options,
  ) {
    final List<pw.Widget> widgets = [];
    final delta = document.toDelta();

    for (final op in delta.toList()) {
      final data = op.data;
      final attributes = op.attributes;

      if (data is! String) continue;

      // Handle block-level formatting
      if (attributes != null) {
        // Headings
        if (attributes.containsKey('header')) {
          final level = attributes['header'];
          final fontSize = level == 1
              ? options.heading1Size
              : level == 2
              ? options.heading2Size
              : options.heading3Size;
          widgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 10, bottom: 5),
              child: pw.Text(
                data.trim(),
                style: pw.TextStyle(font: fonts.bold, fontSize: fontSize),
              ),
            ),
          );
          continue;
        }

        // Lists
        if (attributes.containsKey('list')) {
          final listType = attributes['list'];
          final bullet = listType == 'ordered' ? '  •  ' : '  •  ';
          widgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20, bottom: 2),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(bullet, style: pw.TextStyle(font: fonts.regular)),
                  pw.Expanded(
                    child: pw.Text(
                      data.trim(),
                      style: _getTextStyle(attributes, fonts, options),
                    ),
                  ),
                ],
              ),
            ),
          );
          continue;
        }

        // Code block
        if (attributes.containsKey('code-block')) {
          widgets.add(
            pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 5),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                data,
                style: pw.TextStyle(
                  font: fonts.regular,
                  fontSize: options.bodyFontSize - 2,
                  fontFallback: [pw.Font.courier()],
                ),
              ),
            ),
          );
          continue;
        }

        // Blockquote
        if (attributes.containsKey('blockquote')) {
          widgets.add(
            pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 5),
              padding: const pw.EdgeInsets.only(left: 15, top: 5, bottom: 5),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  left: pw.BorderSide(color: PdfColors.grey, width: 3),
                ),
              ),
              child: pw.Text(
                data.trim(),
                style: pw.TextStyle(
                  font: fonts.italic,
                  fontSize: options.bodyFontSize,
                  color: PdfColors.grey800,
                ),
              ),
            ),
          );
          continue;
        }
      }

      // Regular text with inline formatting
      final lines = data.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].trim().isNotEmpty) {
          widgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Text(
                lines[i],
                style: _getTextStyle(attributes, fonts, options),
              ),
            ),
          );
        } else if (i < lines.length - 1) {
          widgets.add(pw.SizedBox(height: 5));
        }
      }
    }

    return widgets;
  }

  static pw.TextStyle _getTextStyle(
    Map<String, dynamic>? attributes,
    _FontSet fonts,
    PdfExportOptions options,
  ) {
    if (attributes == null) {
      return pw.TextStyle(font: fonts.regular, fontSize: options.bodyFontSize);
    }

    final isBold = attributes.containsKey('bold');
    final isItalic = attributes.containsKey('italic');
    final isUnderline = attributes.containsKey('underline');
    final isStrikethrough = attributes.containsKey('strike');

    // Determine font
    pw.Font font = fonts.regular;
    if (isBold) {
      font = fonts.bold;
    } else if (isItalic) {
      font = fonts.italic;
    }

    // Get color if exists
    PdfColor? color;
    if (attributes.containsKey('color')) {
      try {
        final colorString = attributes['color'] as String;
        final hexColor = colorString.replaceAll('#', '');
        final colorValue = int.parse(hexColor, radix: 16);
        color = PdfColor.fromInt(colorValue | 0xFF000000);
      } catch (e) {
        color = null;
      }
    }

    return pw.TextStyle(
      font: font,
      fontSize: options.bodyFontSize,
      color: color,
      decoration: isUnderline
          ? pw.TextDecoration.underline
          : isStrikethrough
          ? pw.TextDecoration.lineThrough
          : null,
    );
  }

  static String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .substring(0, fileName.length > 50 ? 50 : fileName.length);
  }
}

// ==================== CONFIGURATION CLASSES ====================

class PdfExportOptions {
  final PdfPageFormat pageFormat;
  final pw.EdgeInsets margin;
  final bool includeTitle;
  final bool includeMetadata;
  final bool includeTags;
  final double titleFontSize;
  final double heading1Size;
  final double heading2Size;
  final double heading3Size;
  final double bodyFontSize;
  final double metadataFontSize;
  final double sectionSpacing;

  PdfExportOptions({
    this.pageFormat = PdfPageFormat.a4,
    this.margin = const pw.EdgeInsets.all(40),
    this.includeTitle = true,
    this.includeMetadata = true,
    this.includeTags = true,
    this.titleFontSize = 24,
    this.heading1Size = 20,
    this.heading2Size = 16,
    this.heading3Size = 14,
    this.bodyFontSize = 12,
    this.metadataFontSize = 9,
    this.sectionSpacing = 20,
  });

  /// Preset: Minimal (no metadata)
  factory PdfExportOptions.minimal() {
    return PdfExportOptions(includeMetadata: false, includeTags: false);
  }

  /// Preset: Compact (smaller fonts and margins)
  factory PdfExportOptions.compact() {
    return PdfExportOptions(
      margin: const pw.EdgeInsets.all(20),
      titleFontSize: 20,
      heading1Size: 16,
      heading2Size: 14,
      heading3Size: 12,
      bodyFontSize: 10,
      metadataFontSize: 8,
      sectionSpacing: 10,
    );
  }

  /// Preset: Large print
  factory PdfExportOptions.largePrint() {
    return PdfExportOptions(
      titleFontSize: 32,
      heading1Size: 26,
      // heading2Size = 22,
      heading3Size: 18,
      bodyFontSize: 16,
      metadataFontSize: 12,
      sectionSpacing: 30,
    );
  }
}

class _FontSet {
  final pw.Font regular;
  final pw.Font bold;
  final pw.Font italic;

  _FontSet({required this.regular, required this.bold, required this.italic});
}
