import 'package:athletica/features/workout/domain/entities/workout_exercise_entry.dart';

List<String> _stringList(dynamic value) {
  if (value is List) return value.map((e) => e.toString()).toList();
  return const [];
}

/// Manual fromJson — no codegen per project rules.
class WorkoutExerciseModel extends WorkoutExerciseEntry {
  const WorkoutExerciseModel({
    required super.id,
    required super.nameEn,
    required super.nameAr,
    required super.primaryMuscle,
    required super.secondaryMuscles,
    required super.equipment,
    required super.difficulty,
    required super.exerciseType,
    required super.classification,
    required super.movementPattern,
    required super.fitnessGoals,
    required super.workoutLocation,
    required super.mediaType,
    required super.mediaUrl,
    required super.videoUrl,
    required super.tags,
    required super.isDefault,
    required super.priority,
  });

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseModel(
      id: json['id'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      primaryMuscle: json['primary_muscle'] as String? ?? '',
      secondaryMuscles: _stringList(json['secondary_muscles']),
      equipment: json['equipment'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '',
      exerciseType: json['exercise_type'] as String? ?? '',
      classification: _stringList(json['classification']),
      movementPattern: json['movement_pattern'] as String? ?? '',
      fitnessGoals: _stringList(json['fitness_goals']),
      workoutLocation: json['workout_location'] as String? ?? '',
      mediaType: json['media_type'] as String? ?? '',
      mediaUrl: json['media_url'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
      tags: _stringList(json['tags']),
      isDefault: json['is_default'] as bool? ?? false,
      priority: json['priority'] as String? ?? '',
    );
  }

  WorkoutExerciseEntry toEntity() => WorkoutExerciseEntry(
        id: id,
        nameEn: nameEn,
        nameAr: nameAr,
        primaryMuscle: primaryMuscle,
        secondaryMuscles: secondaryMuscles,
        equipment: equipment,
        difficulty: difficulty,
        exerciseType: exerciseType,
        classification: classification,
        movementPattern: movementPattern,
        fitnessGoals: fitnessGoals,
        workoutLocation: workoutLocation,
        mediaType: mediaType,
        mediaUrl: mediaUrl,
        videoUrl: videoUrl,
        tags: tags,
        isDefault: isDefault,
        priority: priority,
      );

  static WorkoutExerciseEntry? optionalFromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    return WorkoutExerciseModel.fromJson(json).toEntity();
  }
}
