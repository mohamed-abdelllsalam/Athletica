import 'package:athletica/core/utils/bilingual_label.dart';

class FoodCategory {
  const FoodCategory({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameAr,
  });

  final String id;

  /// Default catalog name (backend fallback language).
  final String name;
  final String? nameEn;
  final String? nameAr;

  /// Both API-provided languages joined, e.g. "دجاج / Chicken".
  String get displayName => buildBilingualLabel(
        primary: name,
        arabic: nameAr,
        english: nameEn,
      );
}
