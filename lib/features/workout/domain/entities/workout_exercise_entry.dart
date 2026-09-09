/// Exercise from `GET /workout/exercises` — pure Dart, no Flutter imports.
class WorkoutExerciseEntry {
  const WorkoutExerciseEntry({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.equipment,
    required this.difficulty,
    required this.exerciseType,
    required this.classification,
    required this.movementPattern,
    required this.fitnessGoals,
    required this.workoutLocation,
    required this.mediaType,
    required this.mediaUrl,
    required this.videoUrl,
    required this.tags,
    required this.isDefault,
    required this.priority,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final String equipment;
  final String difficulty;
  final String exerciseType;
  final List<String> classification;
  final String movementPattern;
  final List<String> fitnessGoals;
  final String workoutLocation;
  final String mediaType;
  final String mediaUrl;
  final String videoUrl;
  final List<String> tags;
  final bool isDefault;
  final String priority;

  /// Display name without hardcoded locale branching in widgets — the
  /// caller picks the locale once (e.g. via Localizations).
  String localizedName(bool isArabic) =>
      isArabic && nameAr.isNotEmpty ? nameAr : nameEn;
}

/// Optional filters for `GET /workout/exercises`. All nullable; the
/// datasource only sends non-null values.
class WorkoutExerciseFilters {
  const WorkoutExerciseFilters({
    this.search,
    this.primaryMuscle,
    this.secondaryMuscle,
    this.equipment,
    this.difficulty,
    this.exerciseType,
    this.movementPattern,
    this.workoutLocation,
    this.priority,
    this.goal,
    this.tag,
    this.classification,
    this.isDefault,
    this.page = 1,
    this.pageSize = 20,
  });

  final String? search;
  final String? primaryMuscle;
  final String? secondaryMuscle;
  final String? equipment;
  final String? difficulty;
  final String? exerciseType;
  final String? movementPattern;
  final String? workoutLocation;
  final String? priority;
  final String? goal;
  final String? tag;
  final String? classification;
  final bool? isDefault;
  final int page;
  final int pageSize;

  WorkoutExerciseFilters copyWith({
    String? search,
    int? page,
    int? pageSize,
  }) =>
      WorkoutExerciseFilters(
        search: search ?? this.search,
        primaryMuscle: primaryMuscle,
        secondaryMuscle: secondaryMuscle,
        equipment: equipment,
        difficulty: difficulty,
        exerciseType: exerciseType,
        movementPattern: movementPattern,
        workoutLocation: workoutLocation,
        priority: priority,
        goal: goal,
        tag: tag,
        classification: classification,
        isDefault: isDefault,
        page: page ?? this.page,
        pageSize: pageSize ?? this.pageSize,
      );
}
