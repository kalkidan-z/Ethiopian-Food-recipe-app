import 'package:flutter/foundation.dart';

class Recipe {
  final String id;
  final String name;
  final String category;
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
    required this.category,
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
    String? category,
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
      category: category ?? this.category,
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
      'category': category,
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

  // For Firestore (with documentId)
  factory Recipe.fromMap(Map<String, dynamic> map, String documentId) {
    return Recipe(
      id: documentId,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
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

  // For local storage (SharedPreferences, etc.)
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      cookingTimeMinutes: json['cookingTimeMinutes'] ?? 0,
      difficulty: json['difficulty'] ?? 'Medium',
      isFasting: json['isFasting'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      culturalContext: json['culturalContext'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
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
          category == other.category &&
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
      category.hashCode ^
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
