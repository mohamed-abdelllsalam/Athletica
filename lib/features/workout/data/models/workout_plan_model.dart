import 'package:athletica/features/workout/data/models/workout_exercise_model.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';

int? _optInt(dynamic v) => (v as num?)?.toInt();

class PlanExerciseModel extends PlanExerciseEntry {
  const PlanExerciseModel({
    required super.id,
    required super.exerciseId,
    required super.orderNumber,
    super.sets,
    super.reps,
    super.restTime,
    super.notes,
    super.exercise,
  });

  factory PlanExerciseModel.fromJson(Map<String, dynamic> json) {
    return PlanExerciseModel(
      id: json['id'] as String? ?? '',
      exerciseId: json['exercise_id'] as String? ?? '',
      orderNumber: _optInt(json['order_number']) ?? 0,
      sets: _optInt(json['sets']),
      reps: _optInt(json['reps']),
      restTime: (json['rest_time'] as num?)?.toInt(),
      notes: json['notes'] as String? ?? '',
      exercise: WorkoutExerciseModel.optionalFromJson(json['exercise']),
    );
  }

  PlanExerciseEntry toEntity() => PlanExerciseEntry(
        id: id,
        exerciseId: exerciseId,
        orderNumber: orderNumber,
        sets: sets,
        reps: reps,
        restTime: restTime,
        notes: notes,
        exercise: exercise,
      );
}

class PlanDayModel extends PlanDayEntry {
  const PlanDayModel({
    required super.id,
    required super.title,
    required super.dayNumber,
    required super.isRest,
    super.note,
    required super.exerciseCount,
    required super.exercises,
  });

  factory PlanDayModel.fromJson(Map<String, dynamic> json) {
    final exercises = (json['exercises'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(PlanExerciseModel.fromJson)
        .map((m) => m.toEntity())
        .toList();
    return PlanDayModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      dayNumber: _optInt(json['day_number']) ?? 0,
      isRest: json['is_rest'] as bool? ?? false,
      note: json['note'] as String? ?? '',
      exerciseCount: _optInt(json['exercise_count']) ?? exercises.length,
      exercises: exercises,
    );
  }

  PlanDayEntry toEntity() => PlanDayEntry(
        id: id,
        title: title,
        dayNumber: dayNumber,
        isRest: isRest,
        note: note,
        exerciseCount: exerciseCount,
        exercises: exercises,
      );
}

class WorkoutPlanModel extends WorkoutPlanEntry {
  const WorkoutPlanModel({
    required super.id,
    required super.coachId,
    required super.coachClientId,
    required super.title,
    required super.description,
    required super.startDate,
    required super.cycleDays,
    required super.isActive,
    super.deletedAt,
    required super.dayCount,
    required super.days,
    super.createdAt,
  });

  factory WorkoutPlanModel.fromJson(Map<String, dynamic> json) {
    final days = (json['days'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(PlanDayModel.fromJson)
        .map((m) => m.toEntity())
        .toList();
    return WorkoutPlanModel(
      id: json['id'] as String? ?? '',
      coachId: json['coach_id'] as String? ?? '',
      coachClientId: json['coach_client_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      cycleDays: _optInt(json['cycle_days']) ?? days.length,
      isActive: json['is_active'] as bool? ?? true,
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.tryParse(json['deleted_at'] as String? ?? ''),
      dayCount: _optInt(json['day_count']) ?? days.length,
      days: days,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  static Map<String, dynamic> _dataOf(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    return body;
  }

  static WorkoutPlanModel fromResponse(Map<String, dynamic> body) =>
      WorkoutPlanModel.fromJson(_dataOf(body));

  WorkoutPlanEntry toEntity() => WorkoutPlanEntry(
        id: id,
        coachId: coachId,
        coachClientId: coachClientId,
        title: title,
        description: description,
        startDate: startDate,
        cycleDays: cycleDays,
        isActive: isActive,
        deletedAt: deletedAt,
        dayCount: dayCount,
        days: days,
        createdAt: createdAt,
      );
}
