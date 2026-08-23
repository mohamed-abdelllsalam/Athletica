/// Nutrition template (coach blueprint).
///
/// Summary responses carry [meals] empty; detail responses include meals
/// with their foods and backend-scaled macros.
class NutritionTemplate {
  const NutritionTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.mealCount,
    required this.createdAt,
    this.meals = const [],
  });

  final String id;
  final String title;
  final String description;
  final int mealCount;
  final DateTime createdAt;
  final List<NutritionTemplateMeal> meals;

  int get totalCalories => meals.fold(0, (s, m) => s + m.totalCalories);
  int get totalProtein => meals.fold(0, (s, m) => s + m.totalProtein);
  int get totalCarbs => meals.fold(0, (s, m) => s + m.totalCarbs);
  int get totalFat => meals.fold(0, (s, m) => s + m.totalFat);
}

class NutritionTemplateMeal {
  const NutritionTemplateMeal({
    required this.id,
    required this.mealType,
    required this.mealOrder,
    required this.foods,
    this.notes,
  });

  /// Meal relation UUID (nutrition_template_meals.id).
  final String id;
  final String mealType;
  final int mealOrder;
  final String? notes;
  final List<NutritionTemplateMealFood> foods;

  int get totalCalories => foods.fold(0, (s, f) => s + f.calories.round());
  int get totalProtein => foods.fold(0, (s, f) => s + f.protein.round());
  int get totalCarbs => foods.fold(0, (s, f) => s + f.carbs.round());
  int get totalFat => foods.fold(0, (s, f) => s + f.fat.round());
}

/// Food row inside a template meal.
///
/// [id] is the relation UUID (`nutrition_template_foods.id`) used by the
/// update/remove-food endpoints; [foodId] is the catalog food UUID.
class NutritionTemplateMealFood {
  const NutritionTemplateMealFood({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.servingUnit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final String id;
  final String foodId;
  final String foodName;
  final num quantity;
  final String servingUnit;
  final num calories;
  final num protein;
  final num carbs;
  final num fat;
}
