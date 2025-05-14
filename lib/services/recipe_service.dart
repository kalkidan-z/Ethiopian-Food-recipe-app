import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/recipe.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'recipes';


  // Get all recipes
  Stream<List<Recipe>> getRecipes() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Recipe.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get recipes by category
  Stream<List<Recipe>> getRecipesByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Recipe.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get recipe by ID
  Future<Recipe?> getRecipeById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Recipe.fromMap(doc.data()!, doc.id);
      }
      return null; // Return null if the document does not exist
    } catch (e) {
      print('Error fetching recipe by ID: $e');
      return null;
    }
  }

  // Search recipes by name
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final nameResults = await _firestore
          .collection(_collection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return nameResults.docs.map((doc) {
        return Recipe.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error searching recipes: $e');
      return [];
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isFavorite': isFavorite,
      });
    } catch (e) {
      print('Error toggling favorite status: $e');
    }
  }

  // Get favorite recipes
  Stream<List<Recipe>> getFavoriteRecipes() {
    return _firestore
        .collection(_collection)
        .where('isFavorite', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Recipe.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}