import 'package:athletica/features/coach/plan/domain/entities/food_item.dart';

class FoodItemModel {
  const FoodItemModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.baseGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final int baseGrams;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  factory FoodItemModel.fromJson(Map<String, dynamic> json) => FoodItemModel(
        id: json['id'] as String,
        name: json['name'] as String,
        categoryId: json['categoryId'] as String,
        categoryName: (json['category'] as Map<String, dynamic>)['name'] as String,
        baseGrams: json['baseGrams'] as int,
        calories: json['calories'] as int,
        protein: (json['protein'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        fat: (json['fat'] as num).toDouble(),
      );

  FoodItem toEntity() => FoodItem(
        id: id,
        name: name,
        emoji: _emojiForCategory(categoryName),
        category: categoryName,
        categoryId: categoryId,
        serving: '${baseGrams}g',
        calories: calories,
        proteinGrams: protein.round(),
        carbsGrams: carbs.round(),
        fatGrams: fat.round(),
      );

  static String _emojiForCategory(String categoryName) {
    switch (categoryName) {
      case 'Proteins':
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
        return '🥑';
      default:
        return '🍽️';
    }
  }
}
