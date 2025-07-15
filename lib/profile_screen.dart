import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_recipe_finder/Authprovider.dart';
import 'package:food_recipe_finder/favouritescrren.dart';
import 'package:food_recipe_finder/particular_recipe.dart';
import 'package:food_recipe_finder/rating_star.dart';
import 'package:food_recipe_finder/recipe_model.dart';
import 'package:food_recipe_finder/recipe_page.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isAscending = false; // Track sort state

  @override
  Widget build(BuildContext context) {
    final user = context.watch<authprovider>().user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Color(0xFFA8D5BA)), // Fresh Mint
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                InkWell(
                  child: Icon(
                    Icons.favorite_outline,
                    color: Color(0xFFF4A261), // Warm Apricot
                    size: 30,
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FavouriteScreen()));
                  },
                ),
                SizedBox(width: 16),
                InkWell(
                  child: Icon(
                    Icons.sort,
                    color: _isAscending
                        ? Color.fromARGB(
                            255, 77, 118, 70) // Mossy Hollow when active
                        : Color(0xFF5C6B73), // Slate Gray otherwise
                    size: 30,
                  ),
                  onTap: () {
                    setState(() {
                      _isAscending = !_isAscending; // Toggle sort
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Color(0xFF4A7043), // Mossy Hollow
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      body: Container(
        color: Color(0xFFF8EDE3), // Creamy Ivory background
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${userSnapshot.error}',
                  style: TextStyle(color: Color(0xFF4A7043)), // Mossy Hollow
                ),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFA8D5BA)), // Fresh Mint
                ),
              );
            }

            final userdata = userSnapshot.data!.data() as Map<String, dynamic>;
            final name = userdata['name'] ?? 'Unknown';
            final profilePictureUrl = userdata['profilePictureUrl']?.toString();

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFFF4A261), // Warm Apricot
                          backgroundImage: profilePictureUrl != null
                              ? NetworkImage(profilePictureUrl)
                              : null,
                          child: profilePictureUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFFF8EDE3), // Creamy Ivory
                                )
                              : null,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A7043), // Mossy Hollow
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'This function is currently unavailable'),
                              backgroundColor: Color(0xFFE76F51), 
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFFF4A261), 
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        child: Text('Change Profile Picture'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('recipes')
                        .where('userId', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(
                                color: Color(0xFF4A7043)), 
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
                      if (_isAscending) {
                        recipes.sort((a, b) => a.title.compareTo(b.title));
                      }

                      final recipeCount = recipes.length;

                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'You\'ve shared $recipeCount recipe${recipeCount == 1 ? '' : 's'}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A7043), // Mossy Hollow
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
                                        color: Color(0xFF5C6B73), // Slate Gray
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
                ),
              ],
            );
          },
        ),
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
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                                  content:
                                      Text('Recipe removed from favorites!'),
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
                                  content: Text('Recipe added to favorites!'),
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
