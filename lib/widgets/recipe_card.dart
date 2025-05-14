import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/recipe.dart'; // Import your Recipe model
import 'package:cached_network_image/cached_network_image.dart'; // Import for caching

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final bool isHighlighted;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: isHighlighted ? Colors.yellow[100] : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: recipe.imageUrl.isNotEmpty
                  ? CachedNetworkImage( // Use CachedNetworkImage
                      imageUrl: recipe.imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()), // Show while loading
                      errorWidget: (context, url, error) => Image.asset(
                        //show placeholder
                        'assets/images/placeholder.jpg', // Use a local placeholder
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/images/placeholder.jpg', // Local placeholder for empty URL
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.cookingTimeMinutes} min',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.restaurant,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.difficulty,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipe.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            if (recipe.isFavorite)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.favorite,
                  color: Theme.of(context).primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

