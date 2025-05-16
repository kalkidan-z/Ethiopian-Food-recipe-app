import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/recipe_list_screen.dart';
import 'package:flutter_application_1/widgets/bottom_nav_bar.dart';
import 'package:flutter_application_1/services/recipe_service.dart';
import 'package:flutter_application_1/models/recipe.dart'; // Import the Recipe model

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _quickEasyRecipes = [];
  final Set<String> _favoriteRecipeIds = {};
  final RecipeService _recipeService = RecipeService();
  // Add a map to hold recipes by category
  final Map<String, List<Recipe>> _recipesByCategory = {};
  // Add a list of categories
  final List<String> _categories = [
    "All",
    "Dinner",
    "Lunch",
    "Breakfast",
    "Fasting",
    "Non-Fasting"
  ];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _fetchQuickEasyRecipes();
    _fetchRecipesByCategories(); // Fetch recipes for categories
  }

  Future<void> _fetchCurrentUser() async {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          _currentUserId = user.uid;
          _checkFavoriteStatus(user.uid);
        });
      } else {
        setState(() {
          _currentUserId = null;
          _favoriteRecipeIds.clear();
          for (var recipe in _quickEasyRecipes) {
            recipe['isFavorite'] = false;
          }
        });
      }
    });
  }

  Future<void> _fetchQuickEasyRecipes() async {
    try {
      final querySnapshot = await _firestore
          .collection('recipes')
          .limit(4)
          .get();
      setState(() {
        _quickEasyRecipes = querySnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                  'isFavorite': _favoriteRecipeIds.contains(doc.id),
                })
            .toList();
      });
      if (_currentUserId != null) {
        await _checkFavoriteStatus(_currentUserId!);
      }
    } catch (e) {
      print('Error fetching quick & easy recipes: $e');
    }
  }

  // New method to fetch recipes for each category
  Future<void> _fetchRecipesByCategories() async {
    try {
      for (String category in _categories) {
        // Use the RecipeService to get recipes by category
        _recipeService.getRecipesByCategory(category).listen((List<Recipe> recipes) {
          setState(() {
            _recipesByCategory[category] = recipes;
          });
        });
      }
    } catch (e) {
      print('Error fetching recipes by categories: $e');
    }
  }

  Future<void> _checkFavoriteStatus(String userId) async {
    try {
      final favoritesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();
      _favoriteRecipeIds.clear();
      for (var doc in favoritesSnapshot.docs) {
        _favoriteRecipeIds.add(doc.id);
      }
      setState(() {
        for (var recipe in _quickEasyRecipes) {
          recipe['isFavorite'] = _favoriteRecipeIds.contains(recipe['id']);
        }
      });
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavorite(
      String userId, String recipeId, bool currentIsFavorite) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to manage your favorites.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final favoritesRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(recipeId);
    try {
      if (!currentIsFavorite) {
        final recipeData =
            _quickEasyRecipes.firstWhere((recipe) => recipe['id'] == recipeId);
        await favoritesRef.set(recipeData);
        _favoriteRecipeIds.add(recipeId);
      } else {
        await favoritesRef.delete();
        _favoriteRecipeIds.remove(recipeId);
      }
      setState(() {
        for (var recipe in _quickEasyRecipes) {
          if (recipe['id'] == recipeId) {
            recipe['isFavorite'] = !currentIsFavorite;
            break;
          }
        }
      });
    } catch (e) {
      print('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update favorite status.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/firemesob.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black26,
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "What are you cooking today?",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.redAccent,
                  ),
                  child: const Text(
                    "Cook the best recipes at home",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Categories",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeListScreen(category: "All"),
                          ),
                        );
                      },
                      child: const Text(
                        "View All",
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50, // Height for the category tabs
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryTab(context, "All"),
                      _buildCategoryTab(context, "Dinner"),
                      _buildCategoryTab(context, "Lunch"),
                      _buildCategoryTab(context, "Breakfast"),
                      _buildCategoryTab(context, "Fasting"),
                      _buildCategoryTab(context, "Non-Fasting"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Quick & Easy",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _quickEasyRecipes.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: _quickEasyRecipes
                              .map((recipe) =>
                                  _buildRecipeCard(context, recipe))
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildCategoryTab(BuildContext context, String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeListScreen(category: category),
            ),
          );
        },
        child: Chip(
          label: Text(
            category,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87, // Ensure text is visible
            ),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Map<String, dynamic> recipe) {
    final String recipeId = recipe['id'] ?? '';
    final bool isFavorite = recipe['isFavorite'] ?? false;
    return GestureDetector(
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
      child: Stack(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(recipe['imageUrl'] ?? ''),
                  fit: BoxFit.cover,
                  colorFilter: const ColorFilter.mode(
                    Colors.black45,
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    recipe['name'] ?? 'No Name',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white,
                size: 28,
              ),
              onPressed: () {
                if (_currentUserId != null) {
                  _toggleFavorite(_currentUserId!, recipeId, isFavorite);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Please log in to manage your favorites.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}