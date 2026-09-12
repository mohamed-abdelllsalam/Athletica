import 'package:athletica/features/workout/domain/entities/workout_exercise_entry.dart';

/// Exercise inside a plan day. Order key is `order_number`
/// (templates use `exercise_order`).
class PlanExerciseEntry {
  const PlanExerciseEntry({
    required this.id,
    required this.exerciseId,
    required this.orderNumber,
    this.sets,
    this.reps,
    this.restTime,
    this.notes = '',
    this.exercise,
  });

  final String id;
  final String exerciseId;
  final int orderNumber;
  final int? sets;
  final int? reps;

  /// Rest between sets in seconds (DOC_6 §1.5); null = unset.
  final int? restTime;
  final String notes;
  final WorkoutExerciseEntry? exercise;

  PlanExerciseEntry copyWith({
    int? sets,
    int? reps,
    int? restTime,
    String? notes,
  }) =>
      PlanExerciseEntry(
        id: id,
        exerciseId: exerciseId,
        orderNumber: orderNumber,
        sets: sets ?? this.sets,
        reps: reps ?? this.reps,
        restTime: restTime ?? this.restTime,
        notes: notes ?? this.notes,
        exercise: exercise,
      );
}

class PlanDayEntry {
  const PlanDayEntry({
    required this.id,
    required this.title,
    required this.dayNumber,
    required this.isRest,
    this.note = '',
    required this.exerciseCount,
    required this.exercises,
  });

  final String id;
  final String title;
  final int dayNumber;
  final bool isRest;

  /// Coach tip (DOC_6 §1.4); "" when unset.
  final String note;
  final int exerciseCount;
  final List<PlanExerciseEntry> exercises;
}

/// Full plan from assign / `GET /workout/plans/:pid`.
class WorkoutPlanEntry {
  const WorkoutPlanEntry({
    required this.id,
    required this.coachId,
    required this.coachClientId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.cycleDays,
    required this.isActive,
    this.deletedAt,
    required this.dayCount,
    required this.days,
    this.createdAt,
  });

  final String id;
  final String coachId;
  final String coachClientId;
  final String title;
  final String description;

  /// `YYYY-MM-DD` (Cairo calendar day).
  final String startDate;
  final int cycleDays;
  final bool isActive;
  final DateTime? deletedAt;
  final int dayCount;
  final List<PlanDayEntry> days;
  final DateTime? createdAt;
}
