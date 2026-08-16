import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';

class NutritionTemplateModel {
  const NutritionTemplateModel({
    required this.id,
    required this.trainerId,
    required this.title,
    required this.description,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarb,
    required this.totalFat,
    required this.isPublic,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String trainerId;
  final String title;
  final String description;
  final int totalCalories;
  final int totalProtein;
  final int totalCarb;
  final int totalFat;
  final bool isPublic;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory NutritionTemplateModel.fromJson(Map<String, dynamic> json) =>
      NutritionTemplateModel(
        id: json['id'] as String,
        trainerId: json['trainerId'] as String,
        title: json['title'] as String,
        description: (json['description'] as String?) ?? '',
        totalCalories: (json['totalCalories'] as num?)?.toInt() ?? 0,
        totalProtein: (json['totalProtein'] as num?)?.toInt() ?? 0,
        totalCarb: (json['totalCarb'] as num?)?.toInt() ?? 0,
        totalFat: (json['totalFat'] as num?)?.toInt() ?? 0,
        isPublic: (json['isPublic'] as bool?) ?? false,
        isArchived: (json['isArchived'] as bool?) ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  NutritionTemplate toEntity() => NutritionTemplate(
        id: id,
        trainerId: trainerId,
        title: title,
        description: description,
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarb: totalCarb,
        totalFat: totalFat,
        isPublic: isPublic,
        isArchived: isArchived,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
