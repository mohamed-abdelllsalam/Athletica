class NutritionPlan {
  const NutritionPlan({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.proteinGrams,
    required this.fatGrams,
    required this.carbsGrams,
    required this.planDuration,
    required this.updatedAgo,
    required this.clientCount,
    required this.meals,
    required this.description,
    required this.iconAsset,
  });

  final String id;
  final String name;
  final String category;
  final int calories;
  final int proteinGrams;
  final int fatGrams;
  final int carbsGrams;
  final String planDuration;
  final String updatedAgo;
  final int clientCount;
  final List<Meal> meals;
  final String description;
  final String iconAsset;
}

class Meal {
  Meal({
    required this.id,
    required this.type,
    required this.name,
    required this.calories,
    required this.proteinGrams,
    required this.fatGrams,
    required this.carbsGrams,
    required this.ingredients,
    this.order,
    this.notes,
  });

  final String id;
  final String type;
  final String name;
  final int calories;
  final int proteinGrams;
  final int fatGrams;
  final int carbsGrams;
  List<Ingredient> ingredients;

  /// 1-based position within the template/plan (backend: meal_order).
  final int? order;

  /// Free-form note persisted on the backend meal.
  String? notes;
}

class Ingredient {
  const Ingredient({
    required this.id,
    required this.name,
    required this.emoji,
    required this.serving,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.foodId,
    this.relationId,
  });

  final String id;
  final String name;
  final String emoji;
  final String serving;
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;

  /// Catalog food UUID (backend: food_id). Null for local-only ingredients.
  final String? foodId;

  /// Template/plan food relation UUID (backend relation row id).
  /// Null while the ingredient is not yet persisted.
  final String? relationId;

  /// Quantity in grams derived from [serving] (format "150g").
  int get grams {
    final gMatch = RegExp(r'^(\d+)g$').firstMatch(serving.trim());
    if (gMatch != null) return int.parse(gMatch.group(1)!);
    return 0;
  }
}

