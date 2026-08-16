import 'package:athletica/features/coach/workout_templates/domain/entities/workout_template_day.dart';

class WorkoutTemplateDayModel {
  const WorkoutTemplateDayModel({
    required this.id,
    required this.workoutTemplateId,
    required this.dayIndex,
    required this.label,
  });

  final String id;
  final String workoutTemplateId;
  final int dayIndex;
  final String label;

  factory WorkoutTemplateDayModel.fromJson(Map<String, dynamic> json) =>
      WorkoutTemplateDayModel(
        id: json['id'] as String,
        workoutTemplateId: json['workoutTemplateId'] as String,
        dayIndex: json['dayIndex'] as int,
        label: json['label'] as String,
      );

  WorkoutTemplateDay toEntity() => WorkoutTemplateDay(
        id: id,
        workoutTemplateId: workoutTemplateId,
        dayIndex: dayIndex,
        label: label,
      );
}
