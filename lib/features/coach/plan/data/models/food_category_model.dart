import 'package:athletica/features/coach/plan/domain/entities/food_category.dart';

/// Parses the documented food category:
/// { id, name, name_en, name_ar, _count: { foods } }
class FoodCategoryModel {
  const FoodCategoryModel({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameAr,
  });

  final String id;
  final String name;
  final String? nameEn;
  final String? nameAr;

  factory FoodCategoryModel.fromJson(Map<String, dynamic> json) =>
      FoodCategoryModel(
        id: json['id'] as String,
        name: (json['name'] as String?) ?? '',
        nameEn: json['name_en'] as String?,
        nameAr: json['name_ar'] as String?,
      );

  FoodCategory toEntity() =>
      FoodCategory(id: id, name: name, nameEn: nameEn, nameAr: nameAr);
}
