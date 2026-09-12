import 'package:athletica/features/workout/domain/entities/workout_exercise_entry.dart';

/// One exercise row from `GET /workout/today`.
///
/// [logId] is the per-day log id — it MUST be used for
/// `POST /workout/exercises/{log_id}/complete|uncomplete`.
/// Never use [id] or [exerciseId] for completion.
class TodayExerciseEntry {
  const TodayExerciseEntry({
    required this.logId,
    required this.completed,
    this.completedAt,
    required this.id,
    required this.exerciseId,
    required this.orderNumber,
    this.sets,
    this.reps,
    this.restTime,
    this.notes = '',
    this.exercise,
  });

  final String logId;
  final bool completed;
  final DateTime? completedAt;
  final String id;
  final String exerciseId;
  final int orderNumber;
  final int? sets;
  final int? reps;

  /// Rest between sets in seconds (DOC_6 §1.5); null = unset.
  final int? restTime;
  final String notes;
  final WorkoutExerciseEntry? exercise;

  TodayExerciseEntry copyWith({bool? completed, DateTime? completedAt}) =>
      TodayExerciseEntry(
        logId: logId,
        completed: completed ?? this.completed,
        completedAt: completedAt ?? this.completedAt,
        id: id,
        exerciseId: exerciseId,
        orderNumber: orderNumber,
        sets: sets,
        reps: reps,
        restTime: restTime,
        notes: notes,
        exercise: exercise,
      );

  String displayName(bool isArabic) =>
      exercise?.localizedName(isArabic) ?? exerciseId;
}

/// `GET /workout/today` — null workout means no active plan / rest handled
/// by the repository returning null.
class TodayWorkoutEntry {
  const TodayWorkoutEntry({
    required this.dayId,
    required this.title,
    required this.dayNumber,
    required this.isRest,
    this.note = '',
    required this.exercises,
    required this.dayCompleted,
  });

  final String dayId;
  final String title;
  final int dayNumber;
  final bool isRest;

  /// Coach tip (DOC_6 §1.4); "" when unset.
  final String note;
  final List<TodayExerciseEntry> exercises;
  final bool dayCompleted;

  static const TodayWorkoutEntry emptyRest = TodayWorkoutEntry(
    dayId: '',
    title: '',
    dayNumber: 0,
    isRest: true,
    exercises: [],
    dayCompleted: true,
  );
}

/// Result of complete/uncomplete: updated log + day completion flag.
class ExerciseCompletionResult {
  const ExerciseCompletionResult({
    required this.logId,
    required this.completed,
    this.completedAt,
    required this.dayCompleted,
    this.orderNumber = 0,
  });

  final String logId;
  final bool completed;
  final DateTime? completedAt;
  final bool dayCompleted;
  final int orderNumber;
}
