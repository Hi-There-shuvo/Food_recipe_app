import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe_finder/Addrecipe.dart';
import 'package:food_recipe_finder/Authprovider.dart';
import 'package:food_recipe_finder/LogInScreen.dart';
import 'package:food_recipe_finder/profile_screen.dart';
import 'package:food_recipe_finder/rating_star.dart';
import 'package:food_recipe_finder/recipe_model.dart';
import 'package:provider/provider.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<authprovider>().user;
    return Scaffold(
      backgroundColor: Color(0xFFF8EDE3), // Creamy Ivory
      appBar: AppBar(
        backgroundColor: Color(0xFF4A7043), // Mossy Hollow
        title: Text(
          'Recipes',
          style: TextStyle(
            color: Color(0xFFF8EDE3), // Creamy Ivory
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins', // Add to pubspec.yaml
          ),
        ),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: user != null
                ? FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots()
                : null,
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
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: CircleAvatar(
                      backgroundColor: Color(0xFFF4A261), // Warm Apricot
                      radius: 20,
                      backgroundImage: profilePictureUrl != null
                          ? NetworkImage(profilePictureUrl)
                          : null,
                      child: profilePictureUrl == null
                          ? Icon(
                              Icons.person,
                              size: 20,
                              color: Color(0xFFF8EDE3), // Creamy Ivory
                            )
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFFF8EDE3)), // Creamy Ivory
            onPressed: () async {
              await context.read<authprovider>().logOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LogInScreen()),
              );
            },
          ),
        ],
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
                  color: Color(0xFFE76F51), // Soft Coral
                  fontSize: 16,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFFA8D5BA)), // Fresh Mint
              ),
            );
          }

          final recipes = snapshot.data!.docs
              .map((doc) =>
                  Recipe.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return recipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 80,
                        color: Color(0xFF5C6B73), // Slate Gray
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No recipes available yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF5C6B73), // Slate Gray
                          fontFamily: 'Roboto', // Add to pubspec.yaml
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    return RecipeCard(recipe: recipes[index]);
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFF4A261), // Warm Apricot
        onPressed: () {
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please log in to add a recipe'),
                backgroundColor: Color(0xFFE76F51), // Soft Coral
              ),
            );
            return;
          }
          _showAddRecipeDialog(context);
        },
        child: Icon(Icons.add, color: Color(0xFFF8EDE3)), // Creamy Ivory
        tooltip: 'Add Recipe',
      ),
    );
  }

  void _showAddRecipeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddRecipeDialog(),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({required this.recipe, super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<authprovider>().user;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Color(0xFFF8EDE3), // Creamy Ivory
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Optionally navigate to recipe details
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Image + Favorite
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    // child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                    //     ? Image.network(
                    //         recipe.imageUrl!,
                    //         width: 60,
                    //         height: 60,
                    //         fit: BoxFit.cover,
                    //         color: Color(0xFFF4A261).withOpacity(0.2), // Subtle Warm Apricot overlay
                    //         colorBlendMode: BlendMode.overlay,
                    //         errorBuilder: (context, error, stackTrace) => Container(
                    //           width: 60,
                    //           height: 60,
                    //           color: Color(0xFFA8D5BA), // Fresh Mint
                    //           child: Icon(
                    //             Icons.food_bank,
                    //             color: Color(0xFFF8EDE3), // Creamy Ivory
                    //           ),
                    //         ),
                    //       )
                    child: Container(
                      width: 60,
                      height: 60,
                      color: Color(0xFFA8D5BA), // Fresh Mint
                      child: Icon(
                        Icons.food_bank,
                        color: Color(0xFFF8EDE3), // Creamy Ivory
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: user != null
                        ? FirebaseFirestore.instance
                            .collection('Favourites')
                            .where('userId', isEqualTo: user.uid)
                            .where('recipeId', isEqualTo: recipe.id)
                            .snapshots()
                        : const Stream.empty(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Icon(Icons.error,
                            color: Color(0xFFE76F51)); // Soft Coral
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFA8D5BA)), // Fresh Mint
                          ),
                        );
                      }
                      final isFavourited =
                          snapshot.hasData && snapshot.data!.docs.isNotEmpty;

                      return IconButton(
                        icon: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          transform: Matrix4.identity()
                            ..scale(isFavourited ? 1.2 : 1.0),
                          child: Icon(
                            isFavourited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Color(0xFFF4A261), // Warm Apricot
                            size: 30,
                            shadows: [
                              Shadow(
                                color: Color(0xFF5C6B73)
                                    .withOpacity(0.3), // Slate Gray shadow
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        onPressed: () async {
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please log in first.'),
                                backgroundColor:
                                    Color(0xFFE76F51), // Soft Coral
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
                                  content:
                                      Text('Recipe removed from favorites!'),
                                  backgroundColor:
                                      Color(0xFF4A7043), // Mossy Hollow
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
                                  content: Text('Recipe added to favorites!'),
                                  backgroundColor:
                                      Color(0xFF4A7043), // Mossy Hollow
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor:
                                    Color(0xFFE76F51), // Soft Coral
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Title & Description
              Text(
                recipe.title.isEmpty ? 'No title' : recipe.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A7043), // Mossy Hollow
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                recipe.description.isEmpty
                    ? 'No description'
                    : recipe.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5C6B73), // Slate Gray
                  fontFamily: 'Roboto',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Divider(
                height: 20,
                thickness: 1,
                color: Color(0xFFA8D5BA), // Fresh Mint
              ),

              // Author & Info
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
                        color: Color(0xFF5C6B73), // Slate Gray
                      ),
                    );
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Text(
                      'Submitted by: Unknown',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF5C6B73), // Slate Gray
                      ),
                    );
                  }
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final email = userData['email']?.toString() ?? 'Unknown';
                  return Text(
                    'Submitted by: $email',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF5C6B73), // Slate Gray
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Ingredients and Calories
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  Text(
                    'Ingredients: ${recipe.ingredients.isEmpty ? 'None' : recipe.ingredients.join(', ')}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5C6B73), // Slate Gray
                      fontFamily: 'Roboto',
                    ),
                  ),
                  Text(
                    'Calories: ${recipe.calories} kcal',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5C6B73), // Slate Gray
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Ratings
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
                          color: Color(0xFFF4A261), // Warm Apricot
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Average Rating: ${avgRating.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A7043), // Mossy Hollow
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
