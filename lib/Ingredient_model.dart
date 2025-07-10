class Ingredient {
  final String name;
  final int calories;

  Ingredient({required this.name, required this.calories});

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] ?? '',
      calories: map['calories'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
    };
  }
}
