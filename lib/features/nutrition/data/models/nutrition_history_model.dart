import 'package:athletica/features/nutrition/domain/entities/nutrition_history.dart';

/// Parses `GET /nutrition/history`:
/// `{ "history": [ { date, total_meals, completed_meals, all_completed } ] }`
class NutritionHistoryModel {
  const NutritionHistoryModel({required this.days});

  final List<NutritionHistoryDayModel> days;

  factory NutritionHistoryModel.fromJson(Map<String, dynamic> json) {
    return NutritionHistoryModel(
      days: (json['history'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(NutritionHistoryDayModel.fromJson)
          .toList(),
    );
  }

  List<NutritionHistoryDay> toEntity() =>
      days.map((day) => day.toEntity()).toList();
}

class NutritionHistoryDayModel {
  const NutritionHistoryDayModel({
    required this.date,
    required this.totalMeals,
    required this.completedMeals,
    required this.allCompleted,
  });

  final String date;
  final int totalMeals;
  final int completedMeals;
  final bool allCompleted;

  factory NutritionHistoryDayModel.fromJson(Map<String, dynamic> json) {
    return NutritionHistoryDayModel(
      date: json['date'] as String? ?? '',
      totalMeals: (json['total_meals'] as num?)?.toInt() ?? 0,
      completedMeals: (json['completed_meals'] as num?)?.toInt() ?? 0,
      allCompleted: json['all_completed'] as bool? ?? false,
    );
  }

  NutritionHistoryDay toEntity() => NutritionHistoryDay(
        date: date,
        totalMeals: totalMeals,
        completedMeals: completedMeals,
        allCompleted: allCompleted,
      );
}
