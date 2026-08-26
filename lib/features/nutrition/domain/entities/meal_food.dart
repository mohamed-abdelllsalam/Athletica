import 'package:athletica/core/utils/bilingual_label.dart';

/// A food entry inside a plan meal, with macros already scaled to the
/// quantity by the backend.
class MealFood {
  const MealFood({
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

  /// Default catalog name (backend fallback language).
  final String name;
  final String? nameEn;
  final String? nameAr;
  final num quantity;
  final String servingUnit;
  final num calories;
  final num protein;
  final num carbs;
  final num fat;

  /// Both API-provided languages joined, e.g. "دجاج / Chicken".
  String get displayName => buildBilingualLabel(
        primary: name,
        arabic: nameAr,
        english: nameEn,
      );
}
