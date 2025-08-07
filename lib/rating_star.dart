import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe_finder/Authprovider.dart';
import 'package:provider/provider.dart';

class RatingStars extends StatefulWidget {
  final String recipeId;
  RatingStars({required this.recipeId});

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars> {
  int _rating = 0;

  Future<void> _submitRating(BuildContext context) async {
    final user = context.read<authprovider>().user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to rate this recipe')),
      );
      return;
    }

    // Check if the user has already rated this recipe
    final existingRating = await FirebaseFirestore.instance
        .collection('ratings')
        .where('recipeId', isEqualTo: widget.recipeId)
        .where('userId', isEqualTo: user.uid)
        .get();

    if (existingRating.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have already rated this recipe')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('ratings').add({
        'recipeId': widget.recipeId,
        'userId': user.uid,
        'rating': _rating,
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rating submitted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) {
          return IconButton(
            onPressed: () async {
              setState(() {
                _rating =
                    index + 1;
              });
              await _submitRating(context);
            },
            icon: Icon(
              index < _rating ? Icons.star : Icons.star_border,
              color: Colors.yellow,
            ),
          );
        },
      ),
    );
  }
}
