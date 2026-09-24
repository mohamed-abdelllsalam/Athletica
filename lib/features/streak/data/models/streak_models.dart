import 'package:athletica/core/utils/streak_calendar.dart';
import 'package:athletica/features/streak/domain/entities/streak_data.dart';

class StreakSummaryModel extends StreakSummary {
  const StreakSummaryModel({
    required super.clientId,
    required super.coachClientId,
    required super.from,
    required super.to,
    required super.currentStreak,
    required super.longestStreak,
    required super.totalCompleted,
    required super.totalMissed,
    required super.restDays,
    required super.totalDays,
    required super.completionRate,
  });

  factory StreakSummaryModel.fromJson(Map<String, dynamic> json) =>
      StreakSummaryModel(
        clientId: json['client_id'] as String,
        coachClientId: json['coach_client_id'] as String,
        from: calendarDateKey(parseCalendarDate(json['from'] as String)),
        to: calendarDateKey(parseCalendarDate(json['to'] as String)),
        currentStreak: json['current_streak'] as int,
        longestStreak: json['longest_streak'] as int,
        totalCompleted: json['total_completed'] as int,
        totalMissed: json['total_missed'] as int,
        restDays: (json['rest_days'] as int?) ?? 0,
        totalDays: json['total_days'] as int,
        completionRate: (json['completion_rate'] as num).toDouble(),
      );
}

class WorkoutStreakDayModel extends WorkoutStreakDay {
  const WorkoutStreakDayModel({
    required super.date,
    required super.title,
    required super.status,
    required super.dayNumber,
    required super.dayId,
    required super.isRest,
    required super.total,
    required super.done,
  });

  factory WorkoutStreakDayModel.fromJson(Map<String, dynamic> json) =>
      WorkoutStreakDayModel(
        date: calendarDateKey(parseCalendarDate(json['date'] as String)),
        title: (json['title'] ?? '') as String,
        status: json['is_rest'] == true
            ? StreakDayStatus.rest
            : streakDayStatusFrom(json['status'] as String),
        dayNumber: json['day_number'] as int?,
        dayId: json['day_id'] as String?,
        isRest: (json['is_rest'] ?? false) as bool,
        total: (json['total'] ?? 0) as int,
        done: (json['done'] ?? 0) as int,
      );
}

class NutritionStreakDayModel extends NutritionStreakDay {
  const NutritionStreakDayModel({
    required super.date,
    required super.status,
    required super.totalMeals,
    required super.completedMeals,
  });

  factory NutritionStreakDayModel.fromJson(Map<String, dynamic> json) =>
      NutritionStreakDayModel(
        date: calendarDateKey(parseCalendarDate(json['date'] as String)),
        status: streakDayStatusFrom(json['status'] as String),
        totalMeals: (json['total_meals'] ?? 0) as int,
        completedMeals: (json['completed_meals'] ?? 0) as int,
      );
}
