import 'package:athletica/features/coach/plan/domain/entities/food_item.dart';

/// Parses the documented food catalog item:
/// { id, category_id, name, name_en, name_ar, serving_unit, serving_unit_en,
///   serving_unit_ar, base_grams, calories, protein, carbs, fat,
///   is_archived, created_at }
class FoodItemModel {
  const FoodItemModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.baseGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.categoryName = '',
  });

  final String id;
  final String categoryId;
  final String name;
  final int baseGrams;
  final num calories;
  final num protein;
  final num carbs;
  final num fat;
  final String categoryName;

  factory FoodItemModel.fromJson(
    Map<String, dynamic> json, {
    String categoryName = '',
  }) =>
      FoodItemModel(
        id: json['id'] as String,
        categoryId: (json['category_id'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        baseGrams: (json['base_grams'] as num?)?.toInt() ?? 100,
        calories: (json['calories'] as num?) ?? 0,
        protein: (json['protein'] as num?) ?? 0,
        carbs: (json['carbs'] as num?) ?? 0,
        fat: (json['fat'] as num?) ?? 0,
        categoryName: categoryName,
      );

  FoodItemModel copyWithCategoryName(String newCategoryName) =>
      FoodItemModel(
        id: id,
        categoryId: categoryId,
        name: name,
        baseGrams: baseGrams,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        categoryName: newCategoryName,
      );

  FoodItem toEntity() => FoodItem(
        id: id,
        name: name,
        emoji: _emojiForCategory(categoryName),
        category: categoryName,
        categoryId: categoryId,
        serving: '${baseGrams}g',
        calories: calories.round(),
        proteinGrams: protein.round(),
        carbsGrams: carbs.round(),
        fatGrams: fat.round(),
      );

  static String _emojiForCategory(String categoryName) {
    switch (categoryName) {
      case 'Proteins':
      case 'Meat':
      case 'Seafood':
        return '🍗';
      case 'Fruits':
        return '🍎';
      case 'Vegetables':
        return '🥦';
      case 'Grains':
        return '🌾';
      case 'Legumes':
        return '🫘';
      case 'Dairy':
        return '🥛';
      case 'Healthy Fats':
      case 'Fats & Oils':
      case 'Nuts':
        return '🥑';
      default:
        return '🍽️';
    }
  }
}
