import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:hey_notes/models/note.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class PdfExportService {
  /// Export a single note to PDF
  static Future<File> exportNoteToPdf(Note note) async {
    final pdf = pw.Document();

    // Parse Quill Delta JSON
    final deltaOps = _parseQuillDelta(note.content);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) => [
          // Title
          pw.Header(
            level: 0,
            child: pw.Text(
              note.title,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),

          // Metadata
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Created: ${DateFormat('MMM dd, yyyy').format(note.createdAt)}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              pw.Text(
                'Updated: ${DateFormat('MMM dd, yyyy').format(note.updatedAt)}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          ),

          // Tags
          if (note.tags.isNotEmpty) ...[
            pw.SizedBox(height: 5),
            pw.Wrap(
              spacing: 5,
              children: note.tags
                  .map(
                    (tag) => pw.Container(
                      padding: pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue100,
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Text(
                        tag,
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.blue800,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 20),

          // Content
          ..._buildContentWidgets(deltaOps),
        ],
      ),
    );

    // Save PDF
    final output = await _getOutputFile(note.title);
    await output.writeAsBytes(await pdf.save());
    return output;
  }

  /// Export multiple notes to a single PDF
  static Future<File> exportMultipleNotesToPdf(
    List<Note> notes, {
    String filename = 'notes_export',
  }) async {
    final pdf = pw.Document();

    for (var i = 0; i < notes.length; i++) {
      final note = notes[i];
      final deltaOps = _parseQuillDelta(note.content);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          build: (context) => [
            // Title
            pw.Header(
              level: 0,
              child: pw.Text(
                note.title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),

            // Metadata
            pw.Text(
              'Created: ${DateFormat('MMM dd, yyyy').format(note.createdAt)}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),

            // Tags
            if (note.tags.isNotEmpty) ...[
              pw.SizedBox(height: 5),
              pw.Wrap(
                spacing: 5,
                children: note.tags
                    .map(
                      (tag) => pw.Container(
                        padding: pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue100,
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Text(
                          tag,
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.blue800,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],

            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),

            // Content
            ..._buildContentWidgets(deltaOps),

            // Add page break between notes (except last one)
            if (i < notes.length - 1) pw.SizedBox(height: 40),
          ],
        ),
      );
    }

    // Save PDF
    final output = await _getOutputFile(filename);
    await output.writeAsBytes(await pdf.save());
    return output;
  }

  /// Share PDF file
  static Future<void> sharePdf(File pdfFile) async {
    await Share.shareXFiles([XFile(pdfFile.path)]);
  }

  /// Parse Quill Delta JSON
  static List<Map<String, dynamic>> _parseQuillDelta(String deltaJson) {
    try {
      final decoded = json.decode(deltaJson);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else if (decoded is Map && decoded.containsKey('ops')) {
        return List<Map<String, dynamic>>.from(decoded['ops']);
      }
      return [];
    } catch (e) {
      print('Error parsing Quill Delta: $e');
      return [];
    }
  }

  /// Build PDF widgets from Quill Delta operations
  static List<pw.Widget> _buildContentWidgets(List<Map<String, dynamic>> ops) {
    final widgets = <pw.Widget>[];

    for (var op in ops) {
      final insert = op['insert'];
      final attributes = op['attributes'] as Map<String, dynamic>?;

      if (insert == null) continue;

      // Handle different insert types
      if (insert is String) {
        // Text content
        final text = insert;

        // Handle line breaks
        if (text == '\n') {
          // Check for special formatting (headers, lists, etc.)
          if (attributes != null) {
            if (attributes.containsKey('header')) {
              // Headers are handled by the previous text, so just add spacing
              widgets.add(pw.SizedBox(height: 10));
              continue;
            } else if (attributes.containsKey('list')) {
              // Lists are handled by the previous text
              continue;
            }
          }
          widgets.add(pw.SizedBox(height: 8));
          continue;
        }

        // Build text style
        pw.TextStyle style = pw.TextStyle(fontSize: 12);

        if (attributes != null) {
          // Bold
          if (attributes['bold'] == true) {
            style = style.copyWith(fontWeight: pw.FontWeight.bold);
          }

          // Italic
          if (attributes['italic'] == true) {
            style = style.copyWith(fontStyle: pw.FontStyle.italic);
          }

          // Underline
          if (attributes['underline'] == true) {
            style = style.copyWith(decoration: pw.TextDecoration.underline);
          }

          // Strike
          if (attributes['strike'] == true) {
            style = style.copyWith(decoration: pw.TextDecoration.lineThrough);
          }

          // Header
          if (attributes.containsKey('header')) {
            final level = attributes['header'];
            final fontSize = level == 1 ? 20.0 : (level == 2 ? 16.0 : 14.0);
            style = pw.TextStyle(
              fontSize: fontSize,
              fontWeight: pw.FontWeight.bold,
            );
          }

          // Code block
          if (attributes['code-block'] == true) {
            widgets.add(
              pw.Container(
                padding: pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  text,
                  style: pw.TextStyle(font: pw.Font.times()),
                ),
              ),
            );
            continue;
          }

          // List
          if (attributes.containsKey('list')) {
            final listType = attributes['list'];
            final bullet = listType == 'ordered' ? '1. ' : '• ';
            widgets.add(
              pw.Padding(
                padding: pw.EdgeInsets.only(left: 20, bottom: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(bullet, style: style),
                    pw.Expanded(child: pw.Text(text, style: style)),
                  ],
                ),
              ),
            );
            continue;
          }
        }

        // Regular text
        widgets.add(pw.Text(text, style: style));
      } else if (insert is Map) {
        // Handle embeds (images, etc.)
        // For now, just show a placeholder
        widgets.add(
          pw.Container(
            padding: pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              '[Embedded content: ${insert.keys.first}]',
              style: pw.TextStyle(
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
        );
        widgets.add(pw.SizedBox(height: 8));
      }
    }

    return widgets;
  }

  /// Get output file path
  static Future<File> _getOutputFile(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        '${_sanitizeFileName(name)}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    return File('${directory.path}/$fileName');
  }

  /// Sanitize filename
  static String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .substring(0, name.length > 50 ? 50 : name.length);
  }
}
