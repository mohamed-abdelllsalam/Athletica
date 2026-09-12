import 'package:athletica/features/workout/data/models/workout_exercise_model.dart';
import 'package:athletica/features/workout/domain/entities/today_workout.dart';
import 'package:athletica/features/workout/domain/entities/workout_history.dart';

int? _optInt(dynamic v) => (v as num?)?.toInt();

class TodayExerciseModel extends TodayExerciseEntry {
  const TodayExerciseModel({
    required super.logId,
    required super.completed,
    super.completedAt,
    required super.id,
    required super.exerciseId,
    required super.orderNumber,
    super.sets,
    super.reps,
    super.restTime,
    super.notes,
    super.exercise,
  });

  factory TodayExerciseModel.fromJson(Map<String, dynamic> json) {
    return TodayExerciseModel(
      logId: json['log_id'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.tryParse(json['completed_at'] as String? ?? ''),
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

  TodayExerciseEntry toEntity() => TodayExerciseEntry(
        logId: logId,
        completed: completed,
        completedAt: completedAt,
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

class TodayWorkoutModel extends TodayWorkoutEntry {
  const TodayWorkoutModel({
    required super.dayId,
    required super.title,
    required super.dayNumber,
    required super.isRest,
    super.note,
    required super.exercises,
    required super.dayCompleted,
  });

  /// Returns null when the API answers `{workout: null}` (no active plan).
  static TodayWorkoutModel? fromResponse(Map<String, dynamic> body) {
    final data = body['data'];
    final Map<String, dynamic> root =
        data is Map<String, dynamic> ? data : body;
    final workout = root['workout'];
    if (workout == null) return null;
    if (workout is! Map<String, dynamic>) return null;
    return TodayWorkoutModel.fromJson(workout);
  }

  factory TodayWorkoutModel.fromJson(Map<String, dynamic> json) {
    final exercises = (json['exercises'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(TodayExerciseModel.fromJson)
        .map((m) => m.toEntity())
        .toList();
    return TodayWorkoutModel(
      dayId: json['day_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      dayNumber: _optInt(json['day_number']) ?? 0,
      isRest: json['is_rest'] as bool? ?? false,
      note: json['note'] as String? ?? '',
      exercises: exercises,
      dayCompleted: json['day_completed'] as bool? ?? false,
    );
  }

  TodayWorkoutEntry toEntity() => TodayWorkoutEntry(
        dayId: dayId,
        title: title,
        dayNumber: dayNumber,
        isRest: isRest,
        note: note,
        exercises: exercises,
        dayCompleted: dayCompleted,
      );
}

class ExerciseCompletionModel extends ExerciseCompletionResult {
  const ExerciseCompletionModel({
    required super.logId,
    required super.completed,
    super.completedAt,
    required super.dayCompleted,
    super.orderNumber,
  });

  factory ExerciseCompletionModel.fromResponse(Map<String, dynamic> body) {
    final dynamic rawData = body['data'];
    final Map<String, dynamic> data =
        rawData is Map<String, dynamic> ? rawData : body;
    final log = data['exercise_log'];
    final Map<String, dynamic> logJson =
        log is Map<String, dynamic> ? log : data;
    return ExerciseCompletionModel(
      logId: logJson['log_id'] as String? ?? '',
      completed: logJson['completed'] as bool? ?? false,
      completedAt: logJson['completed_at'] == null
          ? null
          : DateTime.tryParse(logJson['completed_at'] as String? ?? ''),
      dayCompleted: data['day_completed'] as bool? ?? false,
      orderNumber: _optInt(logJson['order_number']) ?? 0,
    );
  }
}

class WorkoutHistoryModel {
  const WorkoutHistoryModel({required this.days});

  final List<WorkoutHistoryDay> days;

  factory WorkoutHistoryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final Map<String, dynamic> root =
        data is Map<String, dynamic> ? data : json;
    final history = (root['history'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => WorkoutHistoryDay(
            date: e['date'] as String? ?? '',
            dayId: e['day_id'] as String? ?? '',
            dayNumber: _optInt(e['day_number']) ?? 0,
            title: e['title'] as String? ?? '',
            isRest: e['is_rest'] as bool? ?? false,
            totalExercises: _optInt(e['total_exercises']) ?? 0,
            completedExercises: _optInt(e['completed_exercises']) ?? 0,
            allCompleted: e['all_completed'] as bool? ?? false,
          ),
        )
        .toList();
    return WorkoutHistoryModel(days: history);
  }
}
