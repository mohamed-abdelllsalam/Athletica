import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';

class NutritionTemplateMealFoodModel {
  const NutritionTemplateMealFoodModel({
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

  factory NutritionTemplateMealFoodModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      NutritionTemplateMealFoodModel(
        id: (json['id'] as String?) ?? '',
        foodId: (json['food_id'] as String?) ?? '',
        foodName: (json['food_name'] as String?) ?? '',
        quantity: (json['quantity'] as num?) ?? 0,
        servingUnit: (json['serving_unit'] as String?) ?? 'g',
        calories: (json['calories'] as num?) ?? 0,
        protein: (json['protein'] as num?) ?? 0,
        carbs: (json['carbs'] as num?) ?? 0,
        fat: (json['fat'] as num?) ?? 0,
      );

  NutritionTemplateMealFood toEntity() => NutritionTemplateMealFood(
        id: id,
        foodId: foodId,
        foodName: foodName,
        quantity: quantity,
        servingUnit: servingUnit,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );
}

class NutritionTemplateMealModel {
  const NutritionTemplateMealModel({
    required this.id,
    required this.mealType,
    required this.mealOrder,
    required this.foods,
    this.notes,
  });

  final String id;
  final String mealType;
  final int mealOrder;
  final String? notes;
  final List<NutritionTemplateMealFoodModel> foods;

  factory NutritionTemplateMealModel.fromJson(Map<String, dynamic> json) =>
      NutritionTemplateMealModel(
        id: (json['id'] as String?) ?? '',
        mealType: (json['meal_type'] as String?) ?? '',
        mealOrder: (json['meal_order'] as num?)?.toInt() ?? 1,
        notes: json['notes'] as String?,
        foods: (json['foods'] as List<dynamic>? ?? [])
            .map((e) => NutritionTemplateMealFoodModel.fromJson(
                e as Map<String, dynamic>))
            .toList(),
      );

  NutritionTemplateMeal toEntity() => NutritionTemplateMeal(
        id: id,
        mealType: mealType,
        mealOrder: mealOrder,
        notes: notes,
        foods: foods.map((f) => f.toEntity()).toList(),
      );
}
