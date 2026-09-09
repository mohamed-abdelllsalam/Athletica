/// One row from `GET /workout/history` (param-less; range is automatic
/// from the active plan's start_date until today).
class WorkoutHistoryDay {
  const WorkoutHistoryDay({
    required this.date,
    required this.dayId,
    required this.dayNumber,
    required this.title,
    required this.isRest,
    required this.totalExercises,
    required this.completedExercises,
    required this.allCompleted,
  });

  final String date;
  final String dayId;
  final int dayNumber;
  final String title;
  final bool isRest;
  final int totalExercises;
  final int completedExercises;
  final bool allCompleted;

  /// Recommended UI mapping from the API docs:
  /// completed → allCompleted; missed → !allCompleted && !isRest && past;
  /// rest → isRest (always complete).
  bool get isCompletedUi => allCompleted || isRest;

  bool isMissed(String todayYmd) =>
      !allCompleted && !isRest && date.compareTo(todayYmd) < 0;
}
