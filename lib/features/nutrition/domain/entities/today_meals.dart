import 'package:athletica/features/nutrition/domain/entities/meal_food.dart';

/// One meal log for today from `GET /nutrition/today`.
class TodayMeal {
  const TodayMeal({
    required this.mealLogId,
    required this.mealId,
    required this.mealType,
    required this.mealOrder,
    this.notes = '',
    required this.completed,
    this.completedAt,
    required this.foods,
  });

  final String mealLogId;
  final String mealId;
  final String mealType;
  final int mealOrder;
  final String notes;
  final bool completed;
  final DateTime? completedAt;
  final List<MealFood> foods;

  num get totalCalories => foods.fold(0, (sum, f) => sum + f.calories);
  num get totalProtein => foods.fold(0, (sum, f) => sum + f.protein);
  num get totalCarbs => foods.fold(0, (sum, f) => sum + f.carbs);
  num get totalFat => foods.fold(0, (sum, f) => sum + f.fat);
}

/// Response of `GET /nutrition/today`. [dayCompleted] is null when there
/// are no meals for the day.
class TodayMeals {
  const TodayMeals({required this.meals, required this.dayCompleted});

  final List<TodayMeal> meals;
  final bool? dayCompleted;

  static const TodayMeals empty = TodayMeals(meals: [], dayCompleted: null);

  List<TodayMeal> get sortedMeals =>
      [...meals]..sort((a, b) => a.mealOrder.compareTo(b.mealOrder));
  int get completedMealCount => meals.where((meal) => meal.completed).length;
  double get completionProgress =>
      meals.isEmpty ? 0 : completedMealCount / meals.length;

  TodayMeals replaceMeal(TodayMeal replacement) {
    final updated = meals
        .map(
          (meal) =>
              meal.mealLogId == replacement.mealLogId ? replacement : meal,
        )
        .toList();
    return TodayMeals(
      meals: updated,
      dayCompleted: updated.isEmpty
          ? null
          : updated.every((meal) => meal.completed),
    );
  }

  num get totalCalories => meals.fold(0, (sum, m) => sum + m.totalCalories);
  num get totalProtein => meals.fold(0, (sum, m) => sum + m.totalProtein);
  num get totalCarbs => meals.fold(0, (sum, m) => sum + m.totalCarbs);
  num get totalFat => meals.fold(0, (sum, m) => sum + m.totalFat);

  /// Calories contributed by each macro, used for the ratio bar.
  num get caloriesFromCarbs => totalCarbs * 4;
  num get caloriesFromProtein => totalProtein * 4;
  num get caloriesFromFat => totalFat * 9;
  num get totalMacroCalories =>
      caloriesFromCarbs + caloriesFromProtein + caloriesFromFat;
}
