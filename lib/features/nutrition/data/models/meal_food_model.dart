import 'package:athletica/features/nutrition/domain/entities/meal_food.dart';

class MealFoodModel {
  const MealFoodModel({
    required this.foodId,
    required this.name,
    required this.quantity,
    required this.servingUnit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final String foodId;
  final String name;
  final num quantity;
  final String servingUnit;
  final num calories;
  final num protein;
  final num carbs;
  final num fat;

  factory MealFoodModel.fromJson(Map<String, dynamic> json) {
    return MealFoodModel(
      foodId: json['food_id'] as String? ?? '',
      name: json['food_name'] as String? ?? '',
      quantity: (json['quantity'] as num?) ?? 0,
      servingUnit: json['serving_unit'] as String? ?? 'g',
      calories: (json['calories'] as num?) ?? 0,
      protein: (json['protein'] as num?) ?? 0,
      carbs: (json['carbs'] as num?) ?? 0,
      fat: (json['fat'] as num?) ?? 0,
    );
  }

  MealFood toEntity() => MealFood(
        foodId: foodId,
        name: name,
        quantity: quantity,
        servingUnit: servingUnit,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );
}
