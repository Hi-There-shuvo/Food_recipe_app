class Ingredient {
  final String name;
  final double calories;
  final double quantity;
  final String unit;
  final String unit2;

  Ingredient(
      {required this.name,
      required this.calories,
      required this.quantity,
      required this.unit , 
      required this.unit2});

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] ?? '',
      calories: (map['calories'] is int)
          ? (map['calories'] as int).toDouble()
          : (map['calories'] ?? 0.0).toDouble(),
      quantity: (map['quantity'] is int)
          ? (map['quantity'] as int).toDouble()
          : (map['quantity'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? 'none',
      unit2: map['unit2'] ?? 'none',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'quantity': quantity,
      'unit': unit,
      'unit2': unit2,
    };
  }
}
