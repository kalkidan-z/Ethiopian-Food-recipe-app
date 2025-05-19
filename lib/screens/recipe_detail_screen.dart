
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/recipe.dart';
import 'package:flutter_application_1/services/recipe_service.dart';
import 'package:flutter_application_1/widgets/bottom_nav_bar.dart';
import 'package:flutter_application_1/widgets/ingredient_list.dart';
import 'package:flutter_application_1/widgets/instruction_list.dart';
import 'package:flutter_application_1/widgets/cultural_context_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeService _recipeService = RecipeService();
  late Future<Recipe?> _recipeFuture;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Define a map for default images based on category
  final Map<String, String> _defaultImages = {
    'Dessert': 'assets/images/dessert_placeholder.jpg',
    'Main Course': 'assets/images/main_course_placeholder.jpg',
    'Appetizer': 'assets/images/appetizer_placeholder.jpg',
    'default': 'assets/images/default_placeholder.jpg', //catch all
  };

  @override
  void initState() {
    super.initState();
    _recipeFuture = _recipeService.getRecipeById(widget.recipeId);
  }

  Future<void> _toggleFavorite(String recipeId, bool currentIsFavorite) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _recipeService.toggleFavorite(recipeId, currentIsFavorite);
      setState(() {
        _recipeFuture =
            _recipeService.getRecipeById(widget.recipeId); // Refresh
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
    return FutureBuilder<Recipe?>(
      future: _recipeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Recipe Details')),
            body: Center(
              child: Text(
                snapshot.hasError
                    ? 'Error: ${snapshot.error}'
                    : 'Recipe not found',
              ),
            ),
          );
        }

        final recipe = snapshot.data!;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    recipe.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 8.0,
                          color: Colors.black54,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: recipe.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) {
                          print(
                              'Error loading image from Firebase: $error, URL: ${recipe.imageUrl}');
                          // Use a local asset image on error,  select based on category
                          String defaultImage =
                              _defaultImages[recipe.category] ??
                                  _defaultImages['default']!;
                          return Image.asset(
                            defaultImage,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      recipe.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _toggleFavorite(recipe.id, recipe.isFavorite);
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe info row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoItem(
                            Icons.timer,
                            '${recipe.cookingTimeMinutes} min',
                          ),
                          _buildInfoItem(
                            Icons.restaurant,
                            recipe.difficulty,
                          ),
                          _buildInfoItem(
                            Icons.category,
                            recipe.category,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recipe.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),

                      // Ingredients
                      Text(
                        'Ingredients',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      IngredientList(ingredients: recipe.ingredients),
                      const SizedBox(height: 24),

                      // Instructions
                      Text(
                        'Instructions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      InstructionList(instructions: recipe.instructions),
                      const SizedBox(height: 24),

                      // Cultural Context
                      Text(
                        'Cultural Context',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      CulturalContextCard(
                        context: recipe.culturalContext, // Pass the string
                      ),
                      const SizedBox(height: 24),

                      // Video if available
                      if (recipe.videoUrl.isNotEmpty) ...[
                        Text(
                          'Video Demonstration',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.play_circle_outline),
                          label: const Text('Watch Video'),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: const BottomNavBar(currentIndex: 0),
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}


