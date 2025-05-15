import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/widgets/bottom_nav_bar.dart'; // Import BottomNavBar
import 'package:flutter_application_1/screens/recipe_list_screen.dart'; // Import RecipeListScreen


class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _favoriteRecipes = [];
  final Set<String> _favoriteRecipeIds = {};

  @override
  void initState() {
    super.initState();
    _fetchFavoriteRecipes();
  }

  Future<void> _fetchFavoriteRecipes() async {
    final user = _auth.currentUser;
    if (user == null) {
      // Handle the case where the user is not logged in.
      setState(() {
        _favoriteRecipes = [];
      });
      return;
    }

    try {
      final favoritesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      _favoriteRecipeIds.clear();
      for (var doc in favoritesSnapshot.docs) {
        _favoriteRecipeIds.add(doc.id);
      }

      // Fetch the complete recipe data based on the IDs in the favorites collection.
      List<Map<String, dynamic>> recipes = [];
      for (var doc in favoritesSnapshot.docs) {
        // Get the recipe data from the favorites document.
        final recipeData = doc.data();
 //Added null check
        recipeData['id'] = doc.id; // Important: Add the document ID to the recipe data.
        recipes.add(recipeData);
            }
      setState(() {
        _favoriteRecipes = recipes;
      });
    } catch (e) {
      print('Error fetching favorite recipes: $e');
      // Show error message
      if (mounted) { //check for the context
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load favorites.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _removeFavorite(String recipeId) async {
    final user = _auth.currentUser;
    if (user == null) {
      return; // Or show a message
    }

    try {
      final favoritesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(recipeId);

      await favoritesRef.delete();
      _favoriteRecipeIds.remove(recipeId); //remove from set

      setState(() {
        _favoriteRecipes.removeWhere((recipe) => recipe['id'] == recipeId);
      });

      // Refresh the list.  Not needed with the setState
      //_fetchFavoriteRecipes();

    } catch (e) {
      print('Error removing favorite: $e');
      if (mounted){ //check for the context
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove from favorites.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: _favoriteRecipes.isEmpty
          ? const Center(
              child: Text('No favorite recipes yet.'),
            )
          : ListView.builder(
              itemCount: _favoriteRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _favoriteRecipes[index];
                return _buildFavoriteRecipeCard(context, recipe);
              },
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2), // Index for favorites
    );
  }

  Widget _buildFavoriteRecipeCard(
      BuildContext context, Map<String, dynamic> recipe) {
    final String recipeId = recipe['id'] ?? ''; //recipe id
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  recipe['imageUrl'] ??
                      '', // Use a placeholder if imageUrl is null
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Display a placeholder if the image fails to load
                    return Container(
                      color: Colors.grey[200], // Light grey background
                      child: const Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey), // Grey icon
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['name'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Category: ${recipe['category'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () {
                _removeFavorite(recipeId);
              },
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeListScreen(
                      category: recipe['category'] ?? "All",
                      initialRecipeId: recipeId,
                    ),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "View Recipe",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

