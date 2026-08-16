import 'package:athletica/features/coach/plan/domain/entities/food_category.dart';

class FoodCategoryModel {
  const FoodCategoryModel({required this.id, required this.name});

  final String id;
  final String name;

  factory FoodCategoryModel.fromJson(Map<String, dynamic> json) =>
      FoodCategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
      );

  FoodCategory toEntity() => FoodCategory(id: id, name: name);
}
