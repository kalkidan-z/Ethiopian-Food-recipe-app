import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/widgets/bottom_nav_bar.dart';
import 'package:flutter_application_1/screens/recipe_detail_screen.dart';

class RecipeListScreen extends StatelessWidget {
  final String category;
  final String? initialRecipeId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RecipeListScreen({
    super.key,
    required this.category,
    this.initialRecipeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('recipes')
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No recipes found for this category'),
            );
          }

          final recipes = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipeData = recipes[index].data() as Map<String, dynamic>;
              final recipeId = recipes[index].id;

              // Print the recipe data to the console for debugging
              print('Recipe ID: $recipeId, Data: $recipeData');

              final isHighlighted = recipeId == initialRecipeId;

              return Card(
                elevation: isHighlighted ? 8 : 4,
                color: isHighlighted ? Colors.yellow[100] : null,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(recipeData['name'] ?? 'No Name'),
                  subtitle: Text('Category: ${recipeData['category'] ?? 'No Category'}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(
                          recipeId: recipeId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}

