import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime createdAt;
  final List<String> ingredients;
  final int calories;

  Recipe({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.ingredients,
    required this.calories,
  });

  factory Recipe.fromMap(Map<String, dynamic> data, String id) {
    return Recipe(
      id: id,
      userId: data['userId']?.toString() ?? '',
      title: data['title']?.toString() ?? 'Untitled',
      description: data['description']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ingredients: List<String>.from(data['ingredients'] ?? []),
      calories: data['calories'] is int
          ? data['calories'] as int
          : int.tryParse(data['calories']?.toString() ?? '0') ?? 0,
    );
  }
}