import 'package:athletica/features/coach/nutrition_templates/data/models/nutrition_template_meal_model.dart';
import 'package:athletica/features/coach/plan/domain/entities/coach_nutrition_plan.dart';

/// Parses the documented plan shape:
/// { id, title, description, is_active, created_at, meal_count, meals?[] }
class NutritionPlanModel {
  const NutritionPlanModel({
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
  final List<NutritionTemplateMealModel> meals;

  factory NutritionPlanModel.fromJson(Map<String, dynamic> json) =>
      NutritionPlanModel(
        id: (json['id'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
        isActive: (json['is_active'] as bool?) ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString()) ??
                DateTime.now()
            : DateTime.now(),
        mealCount: (json['meal_count'] as num?)?.toInt() ?? 0,
        meals: (json['meals'] as List<dynamic>? ?? [])
            .map((e) => NutritionTemplateMealModel.fromJson(
                e as Map<String, dynamic>))
            .toList(),
      );

  CoachNutritionPlan toEntity() => CoachNutritionPlan(
        id: id,
        title: title,
        description: description,
        isActive: isActive,
        createdAt: createdAt,
        mealCount: mealCount,
        meals: meals.map((m) => m.toEntity()).toList(),
      );
}
