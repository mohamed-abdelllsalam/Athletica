import 'package:athletica/core/utils/bilingual_label.dart';

class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.categoryId,
    required this.serving,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.nameEn,
    this.nameAr,
  });

  final String id;

  /// Default catalog name (backend fallback language).
  final String name;
  final String? nameEn;
  final String? nameAr;
  final String emoji;
  final String category;
  final String categoryId;
  final String serving;
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;

  /// Both API-provided languages joined, e.g. "دجاج / Chicken".
  String get displayName => buildBilingualLabel(
        primary: name,
        arabic: nameAr,
        english: nameEn,
      );
}
