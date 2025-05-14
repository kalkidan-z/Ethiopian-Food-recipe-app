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

  // Get recipe by id
  Future<Recipe?> getRecipeById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return Recipe.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Search recipes
  Future<List<Recipe>> searchRecipes(String query) async {
    // Search by name
    final nameResults = await _firestore
        .collection(_collection)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    // Convert to recipes
    final recipes = nameResults.docs.map((doc) {
      return Recipe.fromMap(doc.data(), doc.id);
    }).toList();

    return recipes;
  }

  // Toggle favorite
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    await _firestore.collection(_collection).doc(id).update({
      'isFavorite': isFavorite,
    });
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
