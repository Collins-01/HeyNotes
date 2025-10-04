import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content; // Stores Quill Delta JSON as string

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5, defaultValue: [])
  List<String> tags;

  @HiveField(6)
  String? categoryId;

  @HiveField(7)
  String? color;

  @HiveField(8)
  bool isPinned;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    List<String>? tags,
    this.categoryId,
    this.color,
    this.isPinned = false,
  }) : tags = tags ?? [];

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      tags: map['tags'],
      categoryId: map['categoryId'],
      color: map['color'],
      isPinned: map['isPinned'],
    );
  }

  factory Note.empty() {
    return Note(
      id: '',
      title: '',
      content: _getEmptyQuillContent(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: [],
      categoryId: null,
      color: '',
      isPinned: false,
    );
  }

  // Create a copyWith method for easy updates
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? categoryId,
    String? color,
    bool? isPinned,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      tags: tags ?? this.tags,
      categoryId: categoryId ?? this.categoryId,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  /// Converts the hex color string (e.g., '#FF9E9E') to a Flutter Color
  /// Returns a default color if the color string is invalid
  Color get parsedColor {
    if (color == null || color!.isEmpty) return Colors.grey.shade200;
    try {
      String hexColor = color!;
      if (hexColor.startsWith('#')) {
        hexColor = hexColor.substring(1);
      }
      if (hexColor.length == 3) {
        hexColor = hexColor.split('').map((c) => c * 2).join();
      }
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.grey.shade200;
    }
  }

  /// Converts a Flutter Color to a hex string (e.g., '#FF9E9E')
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  // ==================== QUILL INTEGRATION METHODS ====================

  /// Converts QuillController document to string for storage
  static String quillToString(QuillController controller) {
    final delta = controller.document.toDelta();
    final json = delta.toJson();
    return jsonEncode(json);
  }

  /// Creates a QuillController from the stored content string
  QuillController toQuillController() {
    try {
      if (content.isEmpty) {
        return QuillController.basic();
      }
      final json = jsonDecode(content) as List<dynamic>;
      final doc = Document.fromJson(json);
      return QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      print('Error parsing Quill content: $e');
      return QuillController.basic();
    }
  }

  /// Loads content into an existing QuillController
  void loadIntoController(QuillController controller) {
    try {
      if (content.isEmpty) {
        controller.document = Document();
        return;
      }
      final json = jsonDecode(content) as List<dynamic>;
      final doc = Document.fromJson(json);
      controller.document = doc;
    } catch (e) {
      print('Error loading content into controller: $e');
      controller.document = Document();
    }
  }

  /// Gets plain text from the note content (useful for search/preview)
  String getPlainText() {
    try {
      if (content.isEmpty) return '';
      final json = jsonDecode(content) as List<dynamic>;
      final doc = Document.fromJson(json);
      return doc.toPlainText().trim();
    } catch (e) {
      print('Error getting plain text: $e');
      return '';
    }
  }

  /// Gets a preview of the note (first N characters)
  String getPreview({int maxLength = 100}) {
    final plainText = getPlainText();
    if (plainText.length <= maxLength) return plainText;
    return '${plainText.substring(0, maxLength)}...';
  }

  /// Checks if the note content is empty
  bool get isEmpty {
    final plainText = getPlainText();
    return plainText.isEmpty;
  }

  /// Gets word count from the note
  int get wordCount {
    final plainText = getPlainText();
    if (plainText.isEmpty) return 0;
    return plainText.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  /// Gets character count (excluding whitespace)
  int get characterCount {
    final plainText = getPlainText();
    return plainText.replaceAll(RegExp(r'\s+'), '').length;
  }

  /// Helper method to get empty Quill content as string
  static String _getEmptyQuillContent() {
    return jsonEncode([
      {'insert': '\n'}
    ]);
  }

  /// Creates a new note from QuillController
  static Note fromQuillController({
    required QuillController controller,
    required String title,
    String? id,
    List<String>? tags,
    String? categoryId,
    String? color,
    bool isPinned = false,
  }) {
    return Note(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: quillToString(controller),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: tags,
      categoryId: categoryId,
      color: color,
      isPinned: isPinned,
    );
  }

  /// Updates note with new content from QuillController
  Note updateFromController(QuillController controller, {String? newTitle}) {
    return copyWith(
      title: newTitle ?? title,
      content: Note.quillToString(controller),
      updatedAt: DateTime.now(),
    );
  }
}