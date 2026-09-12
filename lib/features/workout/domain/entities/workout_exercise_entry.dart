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
    this.aliases = const [],
    this.bodyPart = '',
    this.muscleGroup = '',
    this.videoUrlMale = '',
    this.videoUrlFemale = '',
    this.thumbnailUrlMale = '',
    this.thumbnailUrlFemale = '',
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

  /// Searchable alternate names (DOC_6).
  final List<String> aliases;

  /// Broad area, e.g. "back" (DOC_6).
  final String bodyPart;

  /// Grouping label, e.g. "latissimus dorsi" (DOC_6).
  final String muscleGroup;

  /// Demo media from the exercise library (`videos`/`thumbnails` maps with
  /// `male`/`female` keys). Empty when the backend omits them.
  final String videoUrlMale;
  final String videoUrlFemale;
  final String thumbnailUrlMale;
  final String thumbnailUrlFemale;

  /// Display name without hardcoded locale branching in widgets — the
  /// caller picks the locale once (e.g. via Localizations).
  String localizedName(bool isArabic) =>
      isArabic && nameAr.isNotEmpty ? nameAr : nameEn;

  /// Full-text match across everything searchable: names, aliases, target
  /// (primaryMuscle), body part, muscle group, secondary muscles and
  /// equipment. Case-insensitive; blank query matches everything.
  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (nameEn.toLowerCase().contains(q)) return true;
    if (nameAr.toLowerCase().contains(q)) return true;
    if (aliases.any((a) => a.toLowerCase().contains(q))) return true;
    if (primaryMuscle.toLowerCase().contains(q)) return true;
    if (bodyPart.toLowerCase().contains(q)) return true;
    if (muscleGroup.toLowerCase().contains(q)) return true;
    if (secondaryMuscles.any((m) => m.toLowerCase().contains(q))) {
      return true;
    }
    if (equipment.toLowerCase().contains(q)) return true;
    return false;
  }
}

/// Optional filters for `GET /workout/exercises` (DOC_6 §4.1). All nullable;
/// the datasource only sends non-null values.
class WorkoutExerciseFilters {
  const WorkoutExerciseFilters({
    this.search,
    this.bodyPart,
    this.target,
    this.secondaryMuscle,
    this.equipment,
    this.difficulty,
    this.muscleGroup,
    this.compound,
    this.unilateral,
    this.page = 1,
    this.pageSize = 20,
  });

  final String? search;
  final String? bodyPart;
  final String? target;
  final String? secondaryMuscle;
  final String? equipment;
  final String? difficulty;
  final String? muscleGroup;
  final bool? compound;
  final bool? unilateral;
  final int page;
  final int pageSize;

  WorkoutExerciseFilters copyWith({
    String? search,
    int? page,
    int? pageSize,
  }) =>
      WorkoutExerciseFilters(
        search: search ?? this.search,
        bodyPart: bodyPart,
        target: target,
        secondaryMuscle: secondaryMuscle,
        equipment: equipment,
        difficulty: difficulty,
        muscleGroup: muscleGroup,
        compound: compound,
        unilateral: unilateral,
        page: page ?? this.page,
        pageSize: pageSize ?? this.pageSize,
      );
}
