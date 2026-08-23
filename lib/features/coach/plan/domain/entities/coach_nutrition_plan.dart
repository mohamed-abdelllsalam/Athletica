import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';

/// Coach-side nutrition plan (`nutrition_plans`).
///
/// [meals] is empty on list summaries and populated on plan details.
class CoachNutritionPlan {
  const CoachNutritionPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.mealCount,
    this.meals = const [],
  });

  final String id;
  final String title;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final int mealCount;
  final List<NutritionTemplateMeal> meals;

  int get totalCalories => meals.fold(0, (s, m) => s + m.totalCalories);
  int get totalProtein => meals.fold(0, (s, m) => s + m.totalProtein);
  int get totalCarbs => meals.fold(0, (s, m) => s + m.totalCarbs);
  int get totalFat => meals.fold(0, (s, m) => s + m.totalFat);
}
