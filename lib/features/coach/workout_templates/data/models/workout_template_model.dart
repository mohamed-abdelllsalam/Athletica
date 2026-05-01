import 'package:athletica/features/coach/workout_templates/domain/entities/workout_template.dart';

class WorkoutTemplateModel {
  const WorkoutTemplateModel({
    required this.id,
    required this.trainerId,
    required this.title,
    required this.level,
    required this.createdAt,
  });

  final String id;
  final String trainerId;
  final String title;
  final String level;
  final DateTime createdAt;

  factory WorkoutTemplateModel.fromJson(Map<String, dynamic> json) =>
      WorkoutTemplateModel(
        id: json['id'] as String,
        trainerId: json['trainerId'] as String,
        title: json['title'] as String,
        level: json['level'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  WorkoutTemplate toEntity() => WorkoutTemplate(
        id: id,
        trainerId: trainerId,
        title: title,
        level: level,
        createdAt: createdAt,
      );
}
