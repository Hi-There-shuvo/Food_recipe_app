import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe_finder/Authprovider.dart';
import 'package:food_recipe_finder/LogInScreen.dart';
import 'package:food_recipe_finder/profile_screen.dart';
import 'package:food_recipe_finder/rating_star.dart';
import 'package:food_recipe_finder/recipe_model.dart';
import 'package:food_recipe_finder/see_recipe_of_clicked_email.dart';
import 'package:provider/provider.dart';

class ParticularRecipe extends StatelessWidget {
  final Recipe recipe;
  const ParticularRecipe({required this.recipe, super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<authprovider>().user;
    return Scaffold(
      backgroundColor: Color(0xFFF8EDE3),
      appBar: AppBar(
        backgroundColor: Color(0xFF4A7043),
        title: Text(
          'Recipe Details',
          style: TextStyle(
            color: Color(0xFFF8EDE3),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: user != null
                ? FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots()
                : Stream.empty(),
            builder: (context, snapshot) {
              String? profilePictureUrl;
              if (snapshot.hasData && snapshot.data!.exists) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                profilePictureUrl = userData['profilePictureUrl']?.toString();
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Color(0xFFF4A261),
                  radius: 20,
                  backgroundImage: profilePictureUrl != null
                      ? NetworkImage(profilePictureUrl)
                      : null,
                  child: profilePictureUrl == null
                      ? Icon(Icons.person, size: 20, color: Color(0xFFF8EDE3))
                      : null,
                ),
              );
            },
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFFFF8F0),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Image Section
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Color(0xFFFFEFD5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.food_bank,
                        size: 80,
                        color: Color(0xFF588157).withOpacity(0.7),
                      ),
                    ),
                  ),

                  // Favorite Icon
                  Positioned(
                    top: 12,
                    right: 12,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: user != null
                          ? FirebaseFirestore.instance
                              .collection('Favourites')
                              .where('userId', isEqualTo: user.uid)
                              .where('recipeId', isEqualTo: recipe.id)
                              .snapshots()
                          : const Stream.empty(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Icon(Icons.error, color: Color(0xFFE63946));
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Color(0xFFF4A261)),
                          );
                        }

                        final isFavourited =
                            snapshot.hasData && snapshot.data!.docs.isNotEmpty;

                        return IconButton(
                          icon: Icon(
                            isFavourited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Color(0xFFF4A261),
                            size: 32,
                          ),
                          onPressed: () async {
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please log in first.'),
                                  backgroundColor: Color(0xFFE63946),
                                ),
                              );
                              return;
                            }

                            try {
                              if (isFavourited) {
                                await FirebaseFirestore.instance
                                    .collection('Favourites')
                                    .doc(snapshot.data!.docs.first.id)
                                    .delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Removed from favorites!'),
                                    backgroundColor: Color(0xFF588157),
                                  ),
                                );
                              } else {
                                await FirebaseFirestore.instance
                                    .collection('Favourites')
                                    .add({
                                  'userId': user.uid,
                                  'recipeId': recipe.id,
                                  'timestamp': FieldValue.serverTimestamp(),
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added to favorites!'),
                                    backgroundColor: Color(0xFF588157),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Color(0xFFE63946),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                recipe.title.isEmpty ? 'No title' : recipe.title,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Color(0xFF333333),
                ),
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                recipe.description.isEmpty
                    ? 'No description'
                    : recipe.description,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  height: 1.6,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 10),

              // Submitted by
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(recipe.userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                      'Submitted by: Unknown (Error)',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF6B7280),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFFF4A261)),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Text(
                      'Submitted by: Unknown',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF6B7280),
                      ),
                    );
                  }

                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final email = userData['email']?.toString() ?? 'Unknown';

                  return InkWell(
                      child: Text(
                        'Submitted by: $email',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Roboto',
                          color: Color(0xFF333333),
                        ),
                      ),
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SeeRecipeOfClickedEmail(
                                    email: email,
                                    userId: recipe.userId,
                                  ))));
                },
              ),

              Divider(
                color: Color(0xFFD3D3D3),
              ),

              // Ingredient

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4A261).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Ingredient',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A7043),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Calories',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A7043),
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A7043),
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  recipe.ingredients.isEmpty
                      ? const Text(
                          'No ingredients added',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            fontFamily: 'Roboto',
                          ),
                        )
                      : Column(
                          children:
                              recipe.ingredients.asMap().entries.map((entry) {
                            final ingredient = entry.value;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: const Color(0xFFE5E7EB)),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      ingredient.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF333333),
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${ingredient.calories} ${ingredient.unit2.isEmpty ? '' : ingredient.unit2}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF5C6B73),
                                        fontFamily: 'Roboto',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${ingredient.quantity} ${ingredient.unit.isEmpty ? '' : ingredient.unit}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF333333),
                                        fontFamily: 'Roboto',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),

              const SizedBox(height: 12),
              // Method of Cooking
              Text(
                'Method of Cooking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A7043),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                recipe.method.isEmpty ? 'No method provided' : recipe.method,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5C6B73), // Slate Gray
                  fontFamily: 'Roboto',
                ),
              ),

              const SizedBox(height: 12),
              // Total Calories
              Center(
                child: Text(
                  'Total Calories: ${recipe.totalCalories} kcal',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5C6B73), // Slate Gray
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('ratings')
                      .where('recipeId', isEqualTo: recipe.id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text(
                        'No ratings',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF5C6B73), // Slate Gray
                          fontFamily: 'Roboto',
                        ),
                      );
                    }
                    final ratings = snapshot.data!.docs;
                    final avgRating = ratings.isEmpty
                        ? 0.0
                        : ratings
                                .map((doc) => (doc['rating'] as num).toDouble())
                                .reduce((a, b) => a + b) /
                            ratings.length;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: Color(0xFFF4A261),
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Average Rating: ${avgRating.toStringAsFixed(1)} (${ratings.length} review)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A7043),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              RatingStars(recipeId: recipe.id),
            ],
          ),
        ),
      ),
    );
  }
}
