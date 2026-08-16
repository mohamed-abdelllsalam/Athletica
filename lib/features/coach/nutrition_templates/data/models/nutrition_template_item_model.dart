import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template_item.dart';

class NutritionTemplateItemModel {
  const NutritionTemplateItemModel({
    required this.id,
    required this.dayId,
    required this.foodId,
    required this.grams,
  });

  final String id;
  final String dayId;
  final String foodId;
  final int grams;

  factory NutritionTemplateItemModel.fromJson(Map<String, dynamic> json) =>
      NutritionTemplateItemModel(
        id: json['id'] as String,
        dayId: (json['dayId'] as String?) ??
            (json['mealTemplateDayId'] as String?) ??
            '',
        foodId: (json['foodId'] as String?) ?? '',
        grams: (json['grams'] as num?)?.toInt() ?? 100,
      );

  NutritionTemplateItem toEntity() => NutritionTemplateItem(
        id: id,
        dayId: dayId,
        foodId: foodId,
        grams: grams,
      );
}
