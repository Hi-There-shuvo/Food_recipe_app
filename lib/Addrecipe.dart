import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe_finder/Authprovider.dart';
import 'package:food_recipe_finder/Ingredient_model.dart';
import 'package:food_recipe_finder/recipe_categories.dart';
import 'package:food_recipe_finder/recipe_model.dart';
import 'package:provider/provider.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _methodController = TextEditingController();

  final List<Map<String, TextEditingController>> _ingredientControllers = [];
  String? _selectedMainIngredient;
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _addIngredientField();
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add({
        'name': TextEditingController(),
        'calories': TextEditingController(),
        'quantity': TextEditingController(),
        'unit': TextEditingController(),
        'unit2': TextEditingController(),
      });
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      _ingredientControllers[index]['name']?.dispose();
      _ingredientControllers[index]['calories']?.dispose();
      _ingredientControllers[index]['quantity']?.dispose();
      _ingredientControllers[index]['unit']?.dispose();
      _ingredientControllers[index]['unit2']?.dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _methodController.dispose();
    for (var controllers in _ingredientControllers) {
      controllers['name']?.dispose();
      controllers['calories']?.dispose();
    }
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF4A7043),
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFF4A7043),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFF4A261),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE76F51),
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE76F51),
          width: 2,
        ),
      ),
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF4A7043),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A7043),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<authprovider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8EDE3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A7043),
        title: const Text(
          'Add Recipe',
          style: TextStyle(
            color: Color(0xFFF8EDE3),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        elevation: 2,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Basic Info'),
              _buildCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: _inputDecoration('Recipe Title'),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Enter a title'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _inputDecoration('Short Description'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              _sectionTitle('Category & Cuisine'),
              _buildCard(
                child: SingleChildScrollView(
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedMainIngredient,
                          decoration: _inputDecoration('Main Ingredient'),
                          items: Category.mainIngredients
                              .map((ingredient) => DropdownMenuItem(
                                    value: ingredient,
                                    child: Text(ingredient),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedMainIngredient = value),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCountry,
                          decoration: _inputDecoration('Cuisine/Country'),
                          items: Category.countries
                              .map((country) => DropdownMenuItem(
                                    value: country,
                                    child: Text(country),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedCountry = value),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// SECTION: INGREDIENTS
              _sectionTitle('Ingredients'),
              _buildCard(
                  child: Column(
                children: [
                  ..._ingredientControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final controllers = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Ingredient Name
                            SizedBox(
                              width: 150,
                              child: TextFormField(
                                controller: controllers['name'],
                                decoration: _inputDecoration('Ingredient'),
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                        ? 'Required'
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Calories
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller: controllers['calories'],
                                decoration: _inputDecoration('Cal'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Required';
                                  if (double.tryParse(value) == null)
                                    return 'Invalid';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),

                            SizedBox(
                              width: 100,
                              child: DropdownButtonFormField<String>(
                                value: controllers['unit2']?.text.isNotEmpty ==
                                        true
                                    ? controllers['unit2']!.text
                                    : null,
                                decoration: _inputDecoration('Unit'),
                                items: Category.unit1
                                    .map((units) => DropdownMenuItem(
                                          value: units,
                                          child: Text(units),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    controllers['unit2']!.text = value;
                                  }
                                },
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                        ? 'Required'
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 8),

                            /// Quantity
                            SizedBox(
                              width: 90,
                              child: TextFormField(
                                controller: controllers['quantity'],
                                decoration: _inputDecoration('Quantity'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Required';
                                  if (double.tryParse(value) == null)
                                    return 'Invalid';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),

                            /// Unit Dropdown
                            SizedBox(
                              width: 100,
                              child: DropdownButtonFormField<String>(
                                value:
                                    controllers['unit']?.text.isNotEmpty == true
                                        ? controllers['unit']!.text
                                        : null,
                                decoration: _inputDecoration('Unit'),
                                items: Category.unit
                                    .map((units) => DropdownMenuItem(
                                          value: units,
                                          child: Text(units),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    controllers['unit']!.text = value;
                                  }
                                },
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                        ? 'Required'
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 8),

                            /// Remove Button
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Color(0xFFE76F51)),
                              onPressed: _ingredientControllers.length > 1
                                  ? () => _removeIngredientField(index)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Divider + Add Ingredient Button
                  const Divider(height: 20, thickness: 0.8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _addIngredientField,
                      icon: const Icon(Icons.add, color: Color(0xFFF8EDE3)),
                      label: const Text(
                        'Add Ingredient',
                        style: TextStyle(color: Color(0xFFF8EDE3)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF4A261),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              )),

              /// SECTION: METHOD
              _sectionTitle('Cooking Method'),
              _buildCard(
                child: TextFormField(
                  controller: _methodController,
                  decoration: _inputDecoration('Process of Cooking'),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Enter cooking process'
                      : null,
                  maxLines: 4,
                ),
              ),

              // SECTION: Total Calories (calculated)
              _sectionTitle('Total Calories (Calculated)'),
              _buildCard(
                child: Text(
                  '${_calculateTotalCalories().toStringAsFixed(2)} kcal',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A7043),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // SUBMIT BUTTON
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please log in to add a recipe'),
                            backgroundColor: Color(0xFFE76F51),
                          ),
                        );
                        return;
                      }

                      final ingredients = _ingredientControllers.map((entry) {
                        return Ingredient(
                          name: entry['name']!.text.trim(),
                          calories:
                              double.tryParse(entry['calories']!.text) ?? 0,
                          quantity:
                              double.tryParse(entry['quantity']!.text) ?? 0,
                          unit: entry['unit']!.text.trim(),
                          unit2: entry['unit2']!.text.trim(),
                        );
                      }).toList();
                      final recipe = Recipe(
                        id: '',
                        userId: user.uid,
                        title: _titleController.text.trim(),
                        description: _descriptionController.text.trim(),
                        createdAt: DateTime.now(),
                        mainingredient: _selectedMainIngredient ?? '',
                        country: _selectedCountry ?? '',
                        ingredients: ingredients,
                        totalCalories: _calculateTotalCalories(),
                        method: _methodController.text.trim(),
                      );

                      try {
                        print(
                            "✅ Saving recipe: ${recipe.toMap()}"); // Debug log
                        await FirebaseFirestore.instance
                            .collection('recipes')
                            .add(recipe.toMap());
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error: $e',
                            ),
                            backgroundColor: const Color(0xFFE76F51),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A7043),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Add Recipe',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFF8EDE3),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotalCalories() {
    double total = 0.0;
    for (var entry in _ingredientControllers) {
      final calText = entry['calories']?.text ?? '0';
      final cal = double.tryParse(calText) ?? 0;
      final calunit = entry['unit2']?.text ?? '0';
      if (calunit == 'Kcal') {
        total += cal;
      } else if (calunit == 'cal') {
        total += cal / 1000;
      }
    }
    return total;
  }
}
