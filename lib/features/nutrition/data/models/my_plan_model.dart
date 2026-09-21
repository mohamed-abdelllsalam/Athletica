import 'package:athletica/features/nutrition/data/models/meal_food_model.dart';
import 'package:athletica/features/nutrition/domain/entities/my_plan.dart';

/// Parses `GET /nutrition/my/plans` and `GET /nutrition/my/plans/:id`:
/// `{ "plan": { id, title, description, is_active, created_at, meal_count,
///    meals?: [ { id, meal_type, meal_order, notes, foods: [...] } ] } }`.
///
/// `plan` is null when the client has no active plan.
class MyPlanModel {
  const MyPlanModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.mealCount,
    required this.meals,
  });

  final String id;
  final String title;
  final String description;
  final bool isActive;
  final DateTime? createdAt;
  final int mealCount;
  final List<MyPlanMeal> meals;

  /// Returns null when the response carries `plan: null`.
  static MyPlanModel? fromResponse(Map<String, dynamic> json) {
    final plan = json['plan'];
    if (plan == null) return null;
    if (plan is! Map<String, dynamic>) return null;
    return MyPlanModel.fromJson(plan);
  }

  factory MyPlanModel.fromJson(Map<String, dynamic> json) {
    return MyPlanModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      mealCount: (json['meal_count'] as num?)?.toInt() ??
          (json['meals'] as List<dynamic>? ?? []).length,
      meals: (json['meals'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(_mealFromJson)
          .toList(),
    );
  }

  static MyPlanMeal _mealFromJson(Map<String, dynamic> json) {
    return MyPlanMeal(
      id: json['id'] as String? ?? '',
      mealType: json['meal_type'] as String? ?? '',
      mealOrder: (json['meal_order'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String? ?? '',
      foods: (json['foods'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((f) => MealFoodModel.fromJson(f).toEntity())
          .toList(),
    );
  }

  MyPlan toEntity() => MyPlan(
        id: id,
        title: title,
        description: description,
        isActive: isActive,
        createdAt: createdAt,
        mealCount: mealCount,
        meals: meals,
      );
}
