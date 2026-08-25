import 'package:athletica/features/nutrition/domain/entities/meal_food.dart';

/// One meal inside the client's plan
/// (`GET /nutrition/my/plans/:id`).
class MyPlanMeal {
  const MyPlanMeal({
    required this.id,
    required this.mealType,
    required this.mealOrder,
    this.notes = '',
    required this.foods,
  });

  final String id;
  final String mealType;
  final int mealOrder;
  final String notes;
  final List<MealFood> foods;

  num get totalCalories => foods.fold(0, (sum, f) => sum + f.calories);
  num get totalProtein => foods.fold(0, (sum, f) => sum + f.protein);
  num get totalCarbs => foods.fold(0, (sum, f) => sum + f.carbs);
  num get totalFat => foods.fold(0, (sum, f) => sum + f.fat);
}

/// The client's active nutrition plan summary or details.
class MyPlan {
  const MyPlan({
    required this.id,
    required this.title,
    this.description = '',
    this.isActive = true,
    this.createdAt,
    this.mealCount = 0,
    this.meals = const [],
  });

  final String id;
  final String title;
  final String description;
  final bool isActive;
  final DateTime? createdAt;

  /// Meal count reported by the API; falls back to the parsed meals length.
  final int mealCount;

  /// Only populated by the plan-details endpoint.
  final List<MyPlanMeal> meals;

  num get totalCalories =>
      meals.fold(0, (sum, m) => sum + m.totalCalories);
  num get totalProtein => meals.fold(0, (sum, m) => sum + m.totalProtein);
  num get totalCarbs => meals.fold(0, (sum, m) => sum + m.totalCarbs);
  num get totalFat => meals.fold(0, (sum, m) => sum + m.totalFat);
}
