import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/bottom_nav_bar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_application_1/models/recipe.dart';
import 'package:flutter_application_1/services/recipe_service.dart';
import 'package:flutter_application_1/screens/recipe_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final RecipeService _recipeService = RecipeService();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  final Map<String, List<Recipe>> _mealPlans = {}; // Use String keys

  @override
  void initState() {
    super.initState();
    _loadMealPlans();
  }

  // Helper to create a consistent date key string
  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Loads meal plans from SharedPreferences.
  Future<void> _loadMealPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final mealPlansString = prefs.getString('mealPlans');
    if (mealPlansString != null) {
      final decoded = jsonDecode(mealPlansString) as Map<String, dynamic>;
      setState(() {
        _mealPlans.clear();
        decoded.forEach((dateString, recipesJson) {
          final recipes = (recipesJson as List)
              .map((r) => Recipe.fromJson(r as Map<String, dynamic>)) // Cast r to Map<String, dynamic>
              .toList();
          _mealPlans[dateString] = recipes;
        });
      });
    }
  }

  /// Saves meal plans to SharedPreferences.
  Future<void> _saveMealPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _mealPlans.map((date, recipes) =>
        MapEntry(date, recipes.map((r) => r.toJson()).toList()));
    await prefs.setString('mealPlans', jsonEncode(encoded));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              _showShoppingList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meals for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton(
                  onPressed: () {
                    _showAddMealDialog();
                  },
                  child: const Text('Add Meal'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildMealList(),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  /// Builds the list of meals for the selected day.
  Widget _buildMealList() {
    final key = _dateKey(_selectedDay);
    final meals = _mealPlans[key] ?? [];

    if (meals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No meals planned for this day',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Add Meal" to plan your meals',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final recipe = meals[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              recipe.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/placeholder.jpg', // Ensure you have a placeholder image
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          title: Text(recipe.name),
          subtitle: Text('${recipe.cookingTimeMinutes} min • ${recipe.difficulty}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _removeMeal(key, index);
            },
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailScreen(
                  recipeId: recipe.id,
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Shows a dialog to add a meal from available recipes.
  void _showAddMealDialog() async {
    final recipes = await _recipeService.getRecipes().first;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Meal to Plan'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      recipe.imageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/placeholder.jpg', // Ensure you have a placeholder image
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  title: Text(recipe.name),
                  subtitle: Text(recipe.category),
                  onTap: () {
                    _addMealToPlan(recipe);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Adds a recipe to the meal plan for the selected day and saves it.
  Future<void> _addMealToPlan(Recipe recipe) async {
    final key = _dateKey(_selectedDay);
    setState(() {
      if (_mealPlans.containsKey(key)) {
        _mealPlans[key]!.add(recipe);
      } else {
        _mealPlans[key] = [recipe];
      }
    });
    await _saveMealPlans(); // Await saving to ensure persistence
  }

  /// Removes a meal from the plan for the selected day and saves it.
  Future<void> _removeMeal(String key, int index) async {
    setState(() {
      _mealPlans[key]!.removeAt(index);
      if (_mealPlans[key]!.isEmpty) {
        _mealPlans.remove(key);
      }
    });
    await _saveMealPlans(); // Await saving to ensure persistence
  }

  /// Shows the shopping list based on planned meals.
  void _showShoppingList() {
    final allIngredients = <String>{};

    for (var recipes in _mealPlans.values) {
      for (var recipe in recipes) {
        allIngredients.addAll(recipe.ingredients);
      }
    }

    final sortedIngredients = allIngredients.toList()..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shopping List',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          // Implement sharing functionality here
                          // For example, using the 'share_plus' package:
                          // Share.share('Your shopping list:\n${sortedIngredients.join('\n')}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share functionality not implemented yet.')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: sortedIngredients.isEmpty
                      ? Center(
                          child: Text(
                            'No ingredients in your shopping list',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: sortedIngredients.length,
                          itemBuilder: (context, index) {
                            return CheckboxListTile(
                              title: Text(sortedIngredients[index]),
                              value: false, // This would ideally come from a state management solution
                              onChanged: (value) {
                                // In a real app, you would track checked items
                                // For now, it just shows a confirmation
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${sortedIngredients[index]} checked: $value')),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
