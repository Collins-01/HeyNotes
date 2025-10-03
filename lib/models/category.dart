import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1) // Different typeId from Note model
class Category extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final DateTime createdAt;

  Category({required this.name, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      name: map['name'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  Category copyWith({String? name, DateTime? createdAt}) {
    return Category(
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
