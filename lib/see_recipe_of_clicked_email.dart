import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe_finder/Authprovider.dart';
import 'package:food_recipe_finder/particular_recipe.dart';
import 'package:food_recipe_finder/rating_star.dart';
import 'package:food_recipe_finder/recipe_model.dart';
import 'package:provider/provider.dart';

class SeeRecipeOfClickedEmail extends StatefulWidget {
  final String email;
  final String userId;
  const SeeRecipeOfClickedEmail({
    super.key,
    required this.email,
    required this.userId,
  });

  @override
  State<SeeRecipeOfClickedEmail> createState() =>
      _SeeRecipeOfClickedEmailState();
}

class _SeeRecipeOfClickedEmailState extends State<SeeRecipeOfClickedEmail> {
  String? name;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          name = snapshot.docs.first['name'];
          isLoading = false;
        });
      } else {
        setState(() {
          name = "No User Found";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        name = "Error Fetching Name";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EDE3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A7043),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name ?? 'Loading...',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              widget.email,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFE8E8E8),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recipes')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Color(0xFF4A7043)),
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
              .map((doc) => Recipe.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ))
              .toList();

          // Sort recipes if ascending is enabled

          final recipeCount = recipes.length;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'He\'se shared $recipeCount recipe${recipeCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A7043),
                  ),
                ),
              ),
              Expanded(
                child: recipes.isEmpty
                    ? Center(
                        child: Text(
                          'No recipes shared yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF5C6B73),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          return RecipeCard(recipe: recipes[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
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
      color: Color(0xFFF8EDE3),
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ParticularRecipe(
                        recipe: recipe,
                      )));
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
                    child: Container(
                      width: 60,
                      height: 60,
                      color: Color(0xFFA8D5BA),
                      child: Icon(
                        Icons.food_bank,
                        color: Color(0xFFF8EDE3),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                  ),
                  Row(
                    children: [
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
                            return Icon(Icons.error, color: Color(0xFFE76F51));
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFA8D5BA)),
                              ),
                            );
                          }
                          final isFavourited = snapshot.hasData &&
                              snapshot.data!.docs.isNotEmpty;

                          return IconButton(
                            icon: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              transform: Matrix4.identity()
                                ..scale(isFavourited ? 1.2 : 1.0),
                              child: Icon(
                                isFavourited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Color(0xFFF4A261),
                                size: 30,
                                shadows: [
                                  Shadow(
                                    color: Color(0xFF5C6B73).withOpacity(0.3),
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
                                    backgroundColor: Color(0xFFE76F51),
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
                                      content: Text(
                                          'Recipe removed from favorites!'),
                                      backgroundColor: Color(0xFF4A7043),
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
                                      content:
                                          Text('Recipe added to favorites!'),
                                      backgroundColor: Color(0xFF4A7043),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Color(0xFFE76F51),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                recipe.title.isEmpty ? 'No title' : recipe.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A7043),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                recipe.description.isEmpty
                    ? 'No description'
                    : recipe.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5C6B73),
                  fontFamily: 'Roboto',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

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
                        color: Color(0xFF5C6B73),
                      ),
                    );
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Text(
                      'Submitted by: Unknown',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF5C6B73),
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
                      color: Color(0xFF5C6B73),
                    ),
                  );
                },
              ),

              const Divider(
                height: 20,
                thickness: 1,
                color: Color(0xFFA8D5BA),
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
                          color: Color(0xFFF4A261),
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Average Rating: ${avgRating.toStringAsFixed(1)}',
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
