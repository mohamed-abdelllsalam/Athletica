import 'package:athletica/features/coach/nutrition_templates/data/models/nutrition_template_meal_model.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';

/// Parses the documented template shape:
/// { id, title, description, meal_count, created_at, meals?[] }
class NutritionTemplateModel {
  const NutritionTemplateModel({
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
  final List<NutritionTemplateMealModel> meals;

  factory NutritionTemplateModel.fromJson(Map<String, dynamic> json) =>
      NutritionTemplateModel(
        id: (json['id'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
        mealCount: (json['meal_count'] as num?)?.toInt() ?? 0,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString()) ??
                DateTime.now()
            : DateTime.now(),
        meals: (json['meals'] as List<dynamic>? ?? [])
            .map((e) => NutritionTemplateMealModel.fromJson(
                e as Map<String, dynamic>))
            .toList(),
      );

  NutritionTemplate toEntity() => NutritionTemplate(
        id: id,
        title: title,
        description: description,
        mealCount: mealCount,
        createdAt: createdAt,
        meals: meals.map((m) => m.toEntity()).toList(),
      );
}
