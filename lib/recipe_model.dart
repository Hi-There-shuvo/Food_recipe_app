import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_recipe_finder/Ingredient_model.dart';

class Recipe {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime createdAt;
  final String mainingredient;
  final String country;
  final List<Ingredient> ingredients;
  final int totalCalories;
  final String method;

  Recipe({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.mainingredient,
    required this.country,
    required this.ingredients,
    required this.totalCalories,
    required this.method,
  });

  factory Recipe.fromMap(Map<String, dynamic> data, String id) {
    List<Ingredient> ingredients = [];
    final ingredientsData = data['ingredients'];

    if (ingredientsData is List<dynamic>) {
      ingredients = ingredientsData
          .map((item) => Ingredient.fromMap(item as Map<String, dynamic>))
          .toList();
    } else if (ingredientsData is String) {
      ingredients = ingredientsData
          .split(',')
          .map((name) => Ingredient(name: name.trim(), calories: 0))
          .toList();
    }

    return Recipe(
      id: id,
      userId: data['userId']?.toString() ?? '',
      title: data['title']?.toString() ?? 'Untitled',
      description: data['description']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mainingredient: data['mainingredient']?.toString() ?? '',
      country: data['country']?.toString() ?? '',
      ingredients: ingredients,
      totalCalories: data['totalCalories'] is int
          ? data['totalCalories'] as int
          : int.tryParse(data['totalCalories']?.toString() ?? '0') ?? 0,
      method: data['method']?.toString() ?? '', // Added
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'mainingredient': mainingredient,
      'country' : country,
      'ingredients': ingredients.map((e) => e.toMap()).toList(),
      'totalCalories': totalCalories,
      'method': method, 
    };
  }
}
