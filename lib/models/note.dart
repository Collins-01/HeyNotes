import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

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
      content: '',
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

    /// #FF9E9E
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
      // Remove '#' if present and ensure it's a valid hex color
      String hexColor = color!;
      if (hexColor.startsWith('#')) {
        hexColor = hexColor.substring(1);
      }
      // Handle 3-digit hex codes by expanding them to 6 digits
      if (hexColor.length == 3) {
        hexColor = hexColor.split('').map((c) => c * 2).join();
      }
      // Handle 6-digit hex codes by adding full opacity (FF)
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.grey.shade200; // Return a default color on error
    }
  }

  /// Converts a Flutter Color to a hex string (e.g., '#FF9E9E')
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
