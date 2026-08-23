import 'package:athletica/features/coach/plan/domain/entities/food_category.dart';

/// Parses the documented food category:
/// { id, name, name_en, name_ar, _count: { foods } }
class FoodCategoryModel {
  const FoodCategoryModel({required this.id, required this.name});

  final String id;
  final String name;

  factory FoodCategoryModel.fromJson(Map<String, dynamic> json) =>
      FoodCategoryModel(
        id: json['id'] as String,
        name: (json['name'] as String?) ?? '',
      );

  FoodCategory toEntity() => FoodCategory(id: id, name: name);
}
