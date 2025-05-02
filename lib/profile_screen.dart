import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_recipe_finder/Authprovider.dart';
import 'package:food_recipe_finder/favouritescrren.dart';
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
                              backgroundColor: Color(0xFFE76F51), // Soft Coral
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFFF4A261), // Warm Apricot
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
                                color: Color(0xFF4A7043)), // Mossy Hollow
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
                                      return RecipeCard2(
                                          recipe: recipes[index]);
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

class RecipeCard2 extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard2({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFF8EDE3), // Creamy Ivory background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Edit Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.food_bank,
                  size: 50,
                  color: Color(0xFFF4A261), // Warm Apricot
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Text(
                    recipe.title.isEmpty ? 'No title' : recipe.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A7043), // Mossy Hollow
                    ),
                  ),
                ),
                FloatingActionButton(
                  heroTag: null,
                  mini: true,
                  backgroundColor: Color(0xFFF4A261), // Warm Apricot
                  foregroundColor: Color(0xFFF8EDE3), // Creamy Ivory
                  elevation: 4,
                  onPressed: () {
                    // Add update logic
                  },
                  child: const Icon(Icons.edit, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              recipe.description.isEmpty
                  ? 'No description'
                  : recipe.description,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF5C6B73), // Slate Gray
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(
              height: 20,
              thickness: 1,
              color: Color(0xFFA8D5BA), // Fresh Mint
            ),
            // Author, Ingredients, Calories
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          color: Color(0xFF5C6B73), // Slate Gray
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Text(
                        'Submitted by: Unknown',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5C6B73), // Slate Gray
                          fontStyle: FontStyle.italic,
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
                        color: Color(0xFF5C6B73), // Slate Gray
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  'Ingredients: ${recipe.ingredients.isEmpty ? 'None' : recipe.ingredients.join(', ')}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5C6B73), // Slate Gray
                  ),
                ),
                Text(
                  'Calories: ${recipe.calories} kcal',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5C6B73), // Slate Gray
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
                  if (snapshot.hasError) {
                    return Text(
                      'Rating error',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5C6B73), // Slate Gray
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFA8D5BA)), // Fresh Mint
                    );
                  }
                  final ratings = snapshot.data!.docs;
                  final avgRating = ratings.isEmpty
                      ? 0.0
                      : ratings
                              .map((doc) => (doc['rating'] as num).toDouble())
                              .reduce((a, b) => a + b) /
                          ratings.length;
                  return Text(
                    'Average Rating: ${avgRating.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A7043), // Mossy Hollow
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
