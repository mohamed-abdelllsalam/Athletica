enum StreakDayStatus { completed, missed, rest }

StreakDayStatus streakDayStatusFrom(String value) =>
    StreakDayStatus.values.byName(value);

class StreakSummary {
  const StreakSummary({
    required this.clientId,
    required this.coachClientId,
    required this.from,
    required this.to,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompleted,
    required this.totalMissed,
    required this.restDays,
    required this.totalDays,
    required this.completionRate,
  });

  final String clientId;
  final String coachClientId;
  final String from;
  final String to;
  final int currentStreak;
  final int longestStreak;
  final int totalCompleted;
  final int totalMissed;
  final int restDays;
  final int totalDays;
  final double completionRate;
}

class WorkoutStreakDay {
  const WorkoutStreakDay({
    required this.date,
    required this.title,
    required this.status,
    required this.dayNumber,
    required this.dayId,
    required this.isRest,
    required this.total,
    required this.done,
  });

  final String date;
  final String title;
  final StreakDayStatus status;
  final int? dayNumber;
  final String? dayId;
  final bool isRest;
  final int total;
  final int done;
}

class NutritionStreakDay {
  const NutritionStreakDay({
    required this.date,
    required this.status,
    required this.totalMeals,
    required this.completedMeals,
  });

  final String date;
  final StreakDayStatus status;
  final int totalMeals;
  final int completedMeals;
}

class StreakData {
  const StreakData({
    this.workoutSummary,
    this.workoutDays = const [],
    this.nutritionSummary,
    this.nutritionDays = const [],
    this.workoutError,
    this.nutritionError,
  });

  final StreakSummary? workoutSummary;
  final List<WorkoutStreakDay> workoutDays;
  final StreakSummary? nutritionSummary;
  final List<NutritionStreakDay> nutritionDays;
  final String? workoutError;
  final String? nutritionError;
}
