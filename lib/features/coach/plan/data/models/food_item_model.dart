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
    this.nameEn,
    this.nameAr,
    this.categoryName = '',
  });

  final String id;
  final String categoryId;
  final String name;
  final String? nameEn;
  final String? nameAr;
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
        nameEn: json['name_en'] as String?,
        nameAr: json['name_ar'] as String?,
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
        nameEn: nameEn,
        nameAr: nameAr,
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
        nameEn: nameEn,
        nameAr: nameAr,
        emoji: _emojiForCategory(categoryName),
        category: categoryName,
        categoryId: categoryId,
        serving: '${baseGrams}g',
        calories: calories.round(),
        proteinGrams: protein.round(),
        carbsGrams: carbs.round(),
        fatGrams: fat.round(),
      );

  /// Category matching is keyword-based on the combined en/ar label so it
  /// keeps working whichever language the backend sends per category.
  static String _emojiForCategory(String categoryLabel) {
    final s = categoryLabel.toLowerCase();
    if (_containsAny(s, ['protein', 'meat', 'seafood', 'لحوم', 'بروتين'])) {
      return '🍗';
    }
    if (_containsAny(s, ['fruit', 'فواكه'])) return '🍎';
    if (_containsAny(s, ['vegetable', 'خضروات'])) return '🥦';
    if (_containsAny(s, ['grain', 'حبوب'])) return '🌾';
    if (_containsAny(s, ['legume', 'بقوليات'])) return '🫘';
    if (_containsAny(s, ['dairy', 'ألبان', 'الالبان'])) return '🥛';
    if (_containsAny(s, ['fat', 'oil', 'nut', 'دهون', 'زيوت', 'مكسرات'])) {
      return '🥑';
    }
    return '🍽️';
  }

  static bool _containsAny(String haystack, List<String> needles) =>
      needles.any(haystack.contains);
}
