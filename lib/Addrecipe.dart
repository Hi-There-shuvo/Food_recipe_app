import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe_finder/Authprovider.dart';
import 'package:provider/provider.dart';

class AddRecipeDialog extends StatefulWidget {
  @override
  _AddRecipeDialogState createState() => _AddRecipeDialogState();
}

class _AddRecipeDialogState extends State<AddRecipeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _caloriesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _submitRecipe(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final user = context.read<authprovider>().user;
      if (user == null) return;

      try {
        // Split ingredients by comma and trim whitespace
        final ingredients = _ingredientsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        // Parse calories as integer
        final calories = int.parse(_caloriesController.text.trim());

        await FirebaseFirestore.instance.collection('recipes').add({
          'userId': user.uid,
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'ingredients': ingredients,
          'calories': calories,
        });
        Navigator.of(context).pop(); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recipe added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add recipe: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add New Recipe',
        style: TextStyle(
          color: Color(0xFF4A7043), // Mossy Hollow
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      backgroundColor: Color(0xFFF8EDE3), // Creamy Ivory
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Rounded corners
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Recipe Title TextField
                _buildTextField(
                  controller: _titleController,
                  labelText: 'Recipe Title',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12), // Space between text fields

                // Description TextField
                _buildTextField(
                  controller: _descriptionController,
                  labelText: 'Description',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),

                // Ingredients TextField
                _buildTextField(
                  controller: _ingredientsController,
                  labelText: 'Ingredients (comma-separated)',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter at least one ingredient';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),

                // Calories TextField
                _buildTextField(
                  controller: _caloriesController,
                  labelText: 'Calories (kcal)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the calorie count';
                    }
                    if (int.tryParse(value.trim()) == null ||
                        int.parse(value.trim()) < 0) {
                      return 'Please enter a valid non-negative number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF4A7043), // Mossy Hollow
              fontSize: 16,
            ),
          ),
        ),
        // Add Recipe Button
        ElevatedButton(
          onPressed: () => _submitRecipe(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFF4A261), // Warm Apricot
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
          ),
          child: Text(
            'Add Recipe',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build text fields with consistent style
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Color(0xFF5C6B73), // Slate Gray
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12), // Rounded border for input fields
          borderSide: BorderSide(
            color: Color(0xFF5C6B73), // Slate Gray
            width: 1.5,
          ),
        ),
        filled: true,
        fillColor: Colors.white, // White background for text fields
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }
}
