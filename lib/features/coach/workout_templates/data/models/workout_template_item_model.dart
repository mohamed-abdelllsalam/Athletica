import 'package:athletica/features/coach/workout_templates/domain/entities/workout_template_item.dart';

class WorkoutTemplateItemModel {
  const WorkoutTemplateItemModel({
    required this.id,
    required this.workoutTemplateDayId,
    required this.exerciseId,
    required this.order,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.notes,
    this.tempo,
    this.rir,
    this.rpe,
  });

  final String id;
  final String workoutTemplateDayId;
  final String exerciseId;
  final int order;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? notes;
  final String? tempo;
  final int? rir;
  final int? rpe;

  factory WorkoutTemplateItemModel.fromJson(Map<String, dynamic> json) =>
      WorkoutTemplateItemModel(
        id: json['id'] as String,
        workoutTemplateDayId: json['workoutTemplateDayId'] as String,
        exerciseId: json['exerciseId'] as String,
        order: json['order'] as int,
        sets: json['sets'] as int,
        reps: json['reps'] as int,
        restSeconds: json['restSeconds'] as int,
        notes: json['notes'] as String?,
        tempo: json['tempo'] as String?,
        rir: json['rir'] as int?,
        rpe: json['rpe'] as int?,
      );

  WorkoutTemplateItem toEntity() => WorkoutTemplateItem(
        id: id,
        workoutTemplateDayId: workoutTemplateDayId,
        exerciseId: exerciseId,
        order: order,
        sets: sets,
        reps: reps,
        restSeconds: restSeconds,
        notes: notes,
        tempo: tempo,
        rir: rir,
        rpe: rpe,
      );
}
