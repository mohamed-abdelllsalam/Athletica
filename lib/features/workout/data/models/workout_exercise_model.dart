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
    super.aliases,
    super.bodyPart,
    super.muscleGroup,
    super.videoUrlMale,
    super.videoUrlFemale,
    super.thumbnailUrlMale,
    super.thumbnailUrlFemale,
  });

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) {
    // New library shape uses `name` / `target` / `bodyPart` / camelCase
    // `secondaryMuscles`; old snake_case keys stay first for compatibility.
    final videos = json['videos'] is Map<String, dynamic>
        ? json['videos'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final thumbnails = json['thumbnails'] is Map<String, dynamic>
        ? json['thumbnails'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return WorkoutExerciseModel(
      id: json['id'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? json['name'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      primaryMuscle:
          json['primary_muscle'] as String? ??
          json['target'] as String? ??
          json['bodyPart'] as String? ??
          '',
      secondaryMuscles: _stringList(
        json['secondary_muscles'] ?? json['secondaryMuscles'],
      ),
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
      aliases: _stringList(json['aliases']),
      bodyPart: json['bodyPart'] as String? ?? '',
      muscleGroup: json['muscleGroup'] as String? ?? '',
      videoUrlMale: videos['male'] as String? ?? '',
      videoUrlFemale: videos['female'] as String? ?? '',
      thumbnailUrlMale: thumbnails['male'] as String? ?? '',
      thumbnailUrlFemale: thumbnails['female'] as String? ?? '',
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
        aliases: aliases,
        bodyPart: bodyPart,
        muscleGroup: muscleGroup,
        videoUrlMale: videoUrlMale,
        videoUrlFemale: videoUrlFemale,
        thumbnailUrlMale: thumbnailUrlMale,
        thumbnailUrlFemale: thumbnailUrlFemale,
      );

  static WorkoutExerciseEntry? optionalFromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    return WorkoutExerciseModel.fromJson(json).toEntity();
  }
}
