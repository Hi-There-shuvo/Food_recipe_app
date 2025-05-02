import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe_finder/Authprovider.dart';
import 'package:food_recipe_finder/recipe_model.dart';
import 'package:provider/provider.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.read<authprovider>().user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Favourite Recipes',
          style: TextStyle(
            color: Color(0xFF4A7043), // Mossy Hollow
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF4A7043), // Mossy Hollow
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Favourites')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFFA8D5BA)), // Fresh Mint
              ),
            );
          }

          List<Map<String, dynamic>> favouriteList = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          if (favouriteList.isEmpty) {
            return Center(
              child: Text(
                'No Favourites Found!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5C6B73), // Slate Gray
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: favouriteList.length,
            itemBuilder: (context, index) {
              final fav = favouriteList[index];
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('recipes')
                    .where(FieldPath.documentId,
                        isEqualTo: fav['recipeId'].toString())
                    .snapshots(),
                builder: (context, recipesnap) {
                  if (!recipesnap.hasData || recipesnap.data!.docs.isEmpty) {
                    return ListTile(
                      title: Text(
                        'Loading recipe...',
                        style:
                            TextStyle(color: Color(0xFF5C6B73)), // Slate Gray
                      ),
                    );
                  }

                  final recipeDoc = recipesnap.data!.docs.first;
                  final recipe = Recipe.fromMap(
                    recipeDoc.data() as Map<String, dynamic>,
                    recipeDoc.id,
                  );

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      color: Color(0xFFF8EDE3), // Creamy Ivory
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.food_bank,
                                size: 40,
                                color: Color(0xFFF4A261), // Warm Apricot
                              ),
                              title: Text(
                                recipe.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A7043), // Mossy Hollow
                                ),
                              ),
                              subtitle: Text(
                                recipe.description,
                                style: TextStyle(
                                  color: Color(0xFF5C6B73), // Slate Gray
                                ),
                              ),
                            ),
                            Divider(),
                            Text(
                                "Ingredients: ${recipe.ingredients.join(', ')}",
                                style: TextStyle(
                                  color: Color(0xFF5C6B73), // Slate Gray
                                )),
                            SizedBox(height: 8),
                            Text(
                              "Calories: ${recipe.calories} kcal",
                              style: TextStyle(
                                color: Color(0xFF5C6B73), // Slate Gray
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Created on: ${recipe.createdAt.toLocal().toString().split(' ')[0]}",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
