import 'package:flutter/foundation.dart';

class Recipe {
  final String id;
  final String name;
  final String category; // Changed to String
  final String imageUrl;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final int cookingTimeMinutes;
  final String difficulty;
  final bool isFasting;
  final bool isFavorite;
  final String culturalContext;
  final String videoUrl;

  Recipe({
    required this.id,
    required this.name,
    required this.category, // Changed to String
    required this.imageUrl,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.cookingTimeMinutes,
    required this.difficulty,
    this.isFasting = false,
    this.isFavorite = false,
    required this.culturalContext,
    this.videoUrl = '',
  });

  Recipe copyWith({
    String? id,
    String? name,
    String? category, // Changed to String?
    String? imageUrl,
    String? description,
    List<String>? ingredients,
    List<String>? instructions,
    int? cookingTimeMinutes,
    String? difficulty,
    bool? isFasting,
    bool? isFavorite,
    String? culturalContext,
    String? videoUrl,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category, // Changed
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      cookingTimeMinutes: cookingTimeMinutes ?? this.cookingTimeMinutes,
      difficulty: difficulty ?? this.difficulty,
      isFasting: isFasting ?? this.isFasting,
      isFavorite: isFavorite ?? this.isFavorite,
      culturalContext: culturalContext ?? this.culturalContext,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category, // Changed to String
      'imageUrl': imageUrl,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'cookingTimeMinutes': cookingTimeMinutes,
      'difficulty': difficulty,
      'isFasting': isFasting,
      'isFavorite': isFavorite,
      'culturalContext': culturalContext,
      'videoUrl': videoUrl,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map, String documentId) {
    return Recipe(
      id: documentId,
      name: map['name'] ?? '',
      category: map['category'] ?? '', // Changed
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      cookingTimeMinutes: map['cookingTimeMinutes'] ?? 0,
      difficulty: map['difficulty'] ?? 'Medium',
      isFasting: map['isFasting'] ?? false,
      isFavorite: map['isFavorite'] ?? false,
      culturalContext: map['culturalContext'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Recipe{id: $id, name: $name, category: $category, imageUrl: $imageUrl, description: $description, ingredients: $ingredients, instructions: $instructions, cookingTimeMinutes: $cookingTimeMinutes, difficulty: $difficulty, isFasting: $isFasting, isFavorite: $isFavorite, culturalContext: $culturalContext, videoUrl: $videoUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          category == other.category && // Changed
          imageUrl == other.imageUrl &&
          description == other.description &&
          listEquals(ingredients, other.ingredients) &&
          listEquals(instructions, other.instructions) &&
          cookingTimeMinutes == other.cookingTimeMinutes &&
          difficulty == other.difficulty &&
          isFasting == other.isFasting &&
          isFavorite == other.isFavorite &&
          culturalContext == other.culturalContext &&
          videoUrl == other.videoUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      category.hashCode ^ // Changed
      imageUrl.hashCode ^
      description.hashCode ^
      ingredients.hashCode ^
      instructions.hashCode ^
      cookingTimeMinutes.hashCode ^
      difficulty.hashCode ^
      isFasting.hashCode ^
      isFavorite.hashCode ^
      culturalContext.hashCode ^
      videoUrl.hashCode;
}

