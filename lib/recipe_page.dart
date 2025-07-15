import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe_finder/Addrecipe.dart';
import 'package:food_recipe_finder/Authprovider.dart';
import 'package:food_recipe_finder/LogInScreen.dart';
import 'package:food_recipe_finder/particular_recipe.dart';
import 'package:food_recipe_finder/profile_screen.dart';
import 'package:food_recipe_finder/rating_star.dart';
import 'package:food_recipe_finder/recipe_categories.dart';
import 'package:food_recipe_finder/recipe_model.dart';
import 'package:provider/provider.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  String? selectedIngredient;
  String? selectedCountry;

  final String Collection = 'recipes';

  // Get the Firestore stream based on selected filter
  Stream<QuerySnapshot> getRecipesStream() {
    final stream = FirebaseFirestore.instance.collection(Collection);

    if (selectedCountry != null && selectedIngredient == null) {
      return stream.where('country', isEqualTo: selectedCountry).snapshots();
    }

    if (selectedCountry == null && selectedIngredient != null) {
      return stream
          .where('mainingredient', isEqualTo: selectedIngredient)
          .snapshots();
    }
    return stream.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<authprovider>().user;
    return Scaffold(
      backgroundColor: const Color(0xFFF8EDE3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A7043),
        title: const Text(
          'Recipes',
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
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFFF4A261),
                      radius: 20,
                      backgroundImage: profilePictureUrl != null
                          ? NetworkImage(profilePictureUrl)
                          : null,
                      child: profilePictureUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 20,
                              color: Color(0xFFF8EDE3),
                            )
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFF8EDE3)),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Filter by Ingredient',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A7043),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: Category.mainIngredients.length + 1,
              itemBuilder: (context, index) {
                final ingredient =
                    index == 0 ? 'All' : Category.mainIngredients[index - 1];
                final isSelected = ingredient == 'All'
                    ? selectedIngredient == null
                    : selectedIngredient == ingredient;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(ingredient),
                    selected: isSelected,
                    selectedColor: const Color(0xFF4A7043),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFFF8EDE3)
                          : const Color(0xFF5C6B73),
                      fontFamily: 'Roboto',
                    ),
                    onSelected: (selected) {
                      setState(() {
                        selectedIngredient =
                            selected && ingredient != 'All' ? ingredient : null;
                        selectedCountry = null;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          // Filter by Country
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Filter by Cuisine',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A7043),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: Category.countries.length + 1,
              itemBuilder: (context, index) {
                final country =
                    index == 0 ? 'All' : Category.countries[index - 1];
                final isSelected = country == 'All'
                    ? selectedCountry == null
                    : selectedCountry == country;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(country),
                    selected: isSelected,
                    selectedColor: const Color(0xFF4A7043),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFFF8EDE3)
                          : const Color(0xFF5C6B73),
                      fontFamily: 'Roboto',
                    ),
                    onSelected: (selected) {
                      setState(() {
                        selectedCountry =
                            selected && country != 'All' ? country : null;
                        selectedIngredient = null;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 12,
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Recipes After Filtering',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A7043),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getRecipesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFA8D5BA)),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(
                        color: Color(0xFFE76F51),
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 80,
                          color: Color(0xFF5C6B73),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          'No recipes available yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF5C6B73),
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Extract Recipe Id

                final recipeIds =
                    snapshot.data!.docs.map((doc) => doc.id).toList();
                print('Recipe IDs: $recipeIds');

                return FutureBuilder<List<Recipe?>>(
                  future: Future.wait(
                    recipeIds.map((recipeIds) async {
                      final recipeDoc = await FirebaseFirestore.instance
                          .collection('recipes')
                          .doc(recipeIds)
                          .get();
                      print(
                          'Recipe data for ID $recipeIds: ${recipeDoc.exists ? recipeDoc.data() : 'Not found'}');
                      if (!recipeDoc.exists) {
                        return null;
                      }
                      return Recipe.fromMap(
                        recipeDoc.data() as Map<String, dynamic>,
                        recipeIds,
                      );
                    }).toList(),
                  ),
                  builder: (context, recipeSnapshot) {
                    if (recipeSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFA8D5BA)),
                        ),
                      );
                    }

                    if (recipeSnapshot.hasError) {
                      print('FutureBuilder error: ${recipeSnapshot.error}');
                      return Center(
                        child: Text(
                          'Error: ${recipeSnapshot.error}',
                          style: TextStyle(color: Color(0xFFE76F51)),
                        ),
                      );
                    }

                    final recipes = recipeSnapshot.data
                            ?.where((recipe) => recipe != null)
                            .toList() ??
                        [];

                    if (recipes.isEmpty) {
                      return Center(
                        child: Text(
                          'No valid recipes found.',
                          style: TextStyle(color: Color(0xFF5C6B73)),
                        ),
                      );
                    }

                    return ListView.builder(
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          return RecipeCard(recipe: recipes[index]!);
                        });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF4A261),
        onPressed: () {
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please log in to add a recipe'),
                backgroundColor: Color(0xFFE76F51),
              ),
            );
            return;
          }
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddRecipePage()));
        },
        child: const Icon(Icons.add, color: Color(0xFFF8EDE3)),
        tooltip: 'Add Recipe',
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
      color: const Color(0xFFF8EDE3),
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ParticularRecipe(recipe: recipe)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: const Color(0xFFA8D5BA),
                      child: const Icon(
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
                        : Stream<QuerySnapshot>.empty(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Icon(Icons.error,
                            color: Color(0xFFE76F51));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
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
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.identity()
                            ..scale(isFavourited ? 1.2 : 1.0),
                          child: Icon(
                            isFavourited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: const Color(0xFFF4A261),
                            size: 30,
                            shadows: const [
                              Shadow(
                                color: Color(0xFF5C6B73),
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        onPressed: () async {
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
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
                                const SnackBar(
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
                                const SnackBar(
                                  content: Text('Recipe added to favorites!'),
                                  backgroundColor: Color(0xFF4A7043),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: const Color(0xFFE76F51),
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
              Text(
                recipe.title.isEmpty ? 'No title' : recipe.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A7043),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                recipe.description.isEmpty
                    ? 'No description'
                    : recipe.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5C6B73),
                  fontFamily: 'Roboto',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(recipe.userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                      'Submitted by: Unknown (Error)',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF5C6B73),
                      ),
                    );
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text(
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
                    style: const TextStyle(
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
              Center(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('ratings')
                      .where('recipeId', isEqualTo: recipe.id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text(
                        'No ratings',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF5C6B73),
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
                        const Icon(
                          Icons.star,
                          color: Color(0xFFF4A261),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Rating: ${avgRating.toStringAsFixed(1)}',
                          style: const TextStyle(
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
