import 'package:athletica/features/workout/data/models/workout_exercise_model.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';

int? _optInt(dynamic v) => (v as num?)?.toInt();

class TemplateExerciseModel extends TemplateExerciseEntry {
  const TemplateExerciseModel({
    required super.id,
    required super.exerciseId,
    required super.exerciseOrder,
    super.sets,
    super.reps,
    super.notes,
    super.exercise,
  });

  factory TemplateExerciseModel.fromJson(Map<String, dynamic> json) {
    return TemplateExerciseModel(
      id: json['id'] as String? ?? '',
      exerciseId: json['exercise_id'] as String? ?? '',
      exerciseOrder: _optInt(json['exercise_order']) ?? 0,
      sets: _optInt(json['sets']),
      reps: _optInt(json['reps']),
      notes: json['notes'] as String? ?? '',
      exercise: WorkoutExerciseModel.optionalFromJson(json['exercise']),
    );
  }

  TemplateExerciseEntry toEntity() => TemplateExerciseEntry(
        id: id,
        exerciseId: exerciseId,
        exerciseOrder: exerciseOrder,
        sets: sets,
        reps: reps,
        notes: notes,
        exercise: exercise,
      );
}

class TemplateDayModel extends TemplateDayEntry {
  const TemplateDayModel({
    required super.id,
    required super.title,
    required super.dayNumber,
    required super.isRest,
    required super.exerciseCount,
    required super.exercises,
  });

  factory TemplateDayModel.fromJson(Map<String, dynamic> json) {
    final exercises = (json['exercises'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(TemplateExerciseModel.fromJson)
        .map((m) => m.toEntity())
        .toList();
    return TemplateDayModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      dayNumber: _optInt(json['day_number']) ?? 0,
      isRest: json['is_rest'] as bool? ?? false,
      exerciseCount:
          _optInt(json['exercise_count']) ?? exercises.length,
      exercises: exercises,
    );
  }

  TemplateDayEntry toEntity() => TemplateDayEntry(
        id: id,
        title: title,
        dayNumber: dayNumber,
        isRest: isRest,
        exerciseCount: exerciseCount,
        exercises: exercises,
      );
}

class WorkoutTemplateModel extends WorkoutTemplateEntry {
  const WorkoutTemplateModel({
    required super.id,
    required super.title,
    required super.description,
    required super.coachId,
    super.deletedAt,
    required super.dayCount,
    required super.days,
    super.createdAt,
  });

  /// Parses both `{...template}` and `{success,data:{...}}` shapes.
  factory WorkoutTemplateModel.fromJson(Map<String, dynamic> json) {
    final days = (json['days'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(TemplateDayModel.fromJson)
        .map((m) => m.toEntity())
        .toList();
    return WorkoutTemplateModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      coachId: json['coach_id'] as String? ?? '',
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

  static WorkoutTemplateModel fromResponse(Map<String, dynamic> body) =>
      WorkoutTemplateModel.fromJson(_dataOf(body));

  WorkoutTemplateEntry toEntity() => WorkoutTemplateEntry(
        id: id,
        title: title,
        description: description,
        coachId: coachId,
        deletedAt: deletedAt,
        dayCount: dayCount,
        days: days,
      );
}

class WorkoutPlanSummaryModel extends WorkoutPlanSummary {
  const WorkoutPlanSummaryModel({
    required super.id,
    required super.title,
    required super.description,
    required super.isActive,
    required super.dayCount,
    super.createdAt,
  });

  factory WorkoutPlanSummaryModel.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanSummaryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      dayCount: _optInt(json['day_count']) ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  WorkoutPlanSummary toEntity() => WorkoutPlanSummary(
        id: id,
        title: title,
        description: description,
        isActive: isActive,
        dayCount: dayCount,
        createdAt: createdAt,
      );
}
