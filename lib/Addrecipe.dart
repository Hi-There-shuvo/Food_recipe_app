import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe_finder/Authprovider.dart';
import 'package:food_recipe_finder/Ingredient_model.dart';
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
  final _caloriesController = TextEditingController();
  final List<Map<String, TextEditingController>> _ingredientControllers = [];

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
      });
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      _ingredientControllers[index]['name']?.dispose();
      _ingredientControllers[index]['calories']?.dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _methodController.dispose();
    _caloriesController.dispose();
    for (var controllers in _ingredientControllers) {
      controllers['name']?.dispose();
      controllers['calories']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<authprovider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8EDE3), // Creamy Ivory
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A7043), // Mossy Hollow
        title: const Text(
          'Add Recipe',
          style: TextStyle(
            color: Color(0xFFF8EDE3), // Creamy Ivory
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Ingredients
              const Text(
                'Ingredients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A7043), // Mossy Hollow
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              ..._ingredientControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controllers = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controllers['name'],
                          decoration: const InputDecoration(
                            labelText: 'Ingredient Name',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an ingredient';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: controllers['calories'],
                          decoration: const InputDecoration(
                            labelText: 'Calories',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter calories';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Color(0xFFE76F51), // Soft Coral
                        ),
                        onPressed: _ingredientControllers.length > 1
                            ? () => _removeIngredientField(index)
                            : null,
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _addIngredientField,
                icon: const Icon(Icons.add, color: Color(0xFFF8EDE3)),
                label: const Text(
                  'Add Ingredient',
                  style: TextStyle(color: Color(0xFFF8EDE3)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4A261), 
                ),
              ),
              const SizedBox(height: 16),

              // Method of Cooking
              TextFormField(
                controller: _methodController,
                decoration: const InputDecoration(
                  labelText: 'Method of Cooking',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),

              // Total Calories
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Total Calories',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total calories';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please log in to add a recipe'),
                            backgroundColor: Color(0xFFE76F51), // Soft Coral
                          ),
                        );
                        return;
                      }

                      final ingredients = _ingredientControllers
                          .asMap()
                          .entries
                          .map((entry) => Ingredient(
                                name: entry.value['name']!.text.trim(),
                                calories:
                                    int.tryParse(entry.value['calories']!.text) ??
                                        0,
                              ))
                          .toList();

                      final recipe = Recipe(
                        id: '', 
                        userId: user.uid,
                        title: _titleController.text,
                        description: _descriptionController.text,
                        createdAt: DateTime.now(),
                        ingredients: ingredients,
                        totalCalories: int.tryParse(_caloriesController.text) ?? 0,
                        method: _methodController.text, 
                      );

                      try {
                        await FirebaseFirestore.instance
                            .collection('recipes')
                            .add(recipe.toMap());
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: const Color(0xFFE76F51), // Soft Coral
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A7043), // Mossy Hollow
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    'Add Recipe',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFF8EDE3), // Creamy Ivory
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}