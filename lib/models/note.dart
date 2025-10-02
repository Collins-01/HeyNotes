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

  Color get parsedColor => Color(int.parse('0xFF$color'));
}
