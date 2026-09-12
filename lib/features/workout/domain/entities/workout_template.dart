import 'package:athletica/features/workout/domain/entities/workout_exercise_entry.dart';

/// Exercise inside a template day. Note the order key: `exercise_order`
/// (plans/today use `order_number` for the same concept).
/// Template exercises store `sets == null && reps == null`.
class TemplateExerciseEntry {
  const TemplateExerciseEntry({
    required this.id,
    required this.exerciseId,
    required this.exerciseOrder,
    this.sets,
    this.reps,
    this.notes = '',
    this.exercise,
  });

  final String id;
  final String exerciseId;
  final int exerciseOrder;
  final int? sets;
  final int? reps;
  final String notes;
  final WorkoutExerciseEntry? exercise;
}

class TemplateDayEntry {
  const TemplateDayEntry({
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
  final List<TemplateExerciseEntry> exercises;
}

class WorkoutTemplateEntry {
  const WorkoutTemplateEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.coachId,
    this.deletedAt,
    required this.dayCount,
    required this.exerciseCount,
    required this.days,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String coachId;
  final DateTime? deletedAt;
  final int dayCount;

  /// Template-level `exercise_count` from the backend. The list API sends
  /// counts without embedded days, so cards must use this — not the day sum.
  final int exerciseCount;
  final List<TemplateDayEntry> days;
  final DateTime? createdAt;
}

/// Plan-level summary from `GET /workout/plans` (no embedded days).
class WorkoutPlanSummary {
  const WorkoutPlanSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
    required this.dayCount,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final bool isActive;
  final int dayCount;
  final DateTime? createdAt;
}
