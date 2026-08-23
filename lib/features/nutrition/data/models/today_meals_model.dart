import 'package:athletica/features/nutrition/data/models/meal_food_model.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';

/// Parses `GET /nutrition/today`:
/// `{ "meals": [ { meal_log_id, meal_id, meal_type, meal_order, notes,
///    completed, completed_at, foods: [...] } ], "day_completed": bool|null }`
class TodayMealsModel {
  const TodayMealsModel({required this.meals, required this.dayCompleted});

  final List<Map<String, dynamic>> meals;
  final bool? dayCompleted;

  factory TodayMealsModel.fromJson(Map<String, dynamic> json) {
    return TodayMealsModel(
      meals: (json['meals'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList(),
      dayCompleted: json['day_completed'] as bool?,
    );
  }

  static TodayMeal _mealFromJson(Map<String, dynamic> json) {
    return TodayMeal(
      mealLogId: json['meal_log_id'] as String? ?? '',
      mealId: json['meal_id'] as String? ?? '',
      mealType: json['meal_type'] as String? ?? '',
      mealOrder: (json['meal_order'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      completedAt: DateTime.tryParse(json['completed_at'] as String? ?? ''),
      foods: (json['foods'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((f) => MealFoodModel.fromJson(f).toEntity())
          .toList(),
    );
  }

  TodayMeals toEntity() => TodayMeals(
        meals: meals.map(_mealFromJson).toList(),
        dayCompleted: dayCompleted,
      );
}
