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
    this.nameEn,
    this.nameAr,
  });

  final String foodId;
  final String name;
  final num quantity;
  final String servingUnit;
  final num calories;
  final num protein;
  final num carbs;
  final num fat;
  final String? nameEn;
  final String? nameAr;

  factory MealFoodModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['food_name'] as String? ?? '';
    final nameEn = json['food_name_en'] as String? ??
        json['name_en'] as String?;
    final nameAr = json['food_name_ar'] as String? ??
        json['name_ar'] as String?;
    return MealFoodModel(
      foodId: json['food_id'] as String? ?? '',
      name: rawName,
      quantity: (json['quantity'] as num?) ?? 0,
      servingUnit: json['serving_unit'] as String? ?? 'g',
      calories: (json['calories'] as num?) ?? 0,
      protein: (json['protein'] as num?) ?? 0,
      carbs: (json['carbs'] as num?) ?? 0,
      fat: (json['fat'] as num?) ?? 0,
      nameEn: nameEn,
      nameAr: nameAr,
    );
  }

  MealFood toEntity() => MealFood(
        foodId: foodId,
        name: name,
        nameEn: nameEn,
        nameAr: nameAr,
        quantity: quantity,
        servingUnit: servingUnit,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );
}
