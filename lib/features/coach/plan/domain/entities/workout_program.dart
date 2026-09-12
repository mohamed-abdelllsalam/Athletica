import 'package:athletica/core/utils/bilingual_label.dart';

class WorkoutProgram {
  WorkoutProgram({
    required this.id,
    required this.name,
    required this.category,
    required this.splitType,
    required this.updatedAgo,
    required this.clientCount,
    required this.description,
    required this.iconAsset,
    required this.days,
    int? totalExercises,
  }) : totalExercises =
           totalExercises ?? days.fold(0, (sum, d) => sum + d.exerciseCount);

  final String id;
  final String name;
  final String category;
  final String splitType;
  final String updatedAgo;
  final int clientCount;
  final String description;
  final String iconAsset;
  final List<ProgramDay> days;

  /// Template-level backend `exercise_count` when mapped from an API
  /// response (the list API sends counts without embedded days),
  /// otherwise the real total across all days.
  final int totalExercises;
}

class ProgramDay {
  ProgramDay({
    required this.dayNumber,
    required this.name,
    required this.durationMinutes,
    required this.exercises,
    this.isRest = false,
    this.note = '',
    int? exerciseCount,
  }) : exerciseCount = exerciseCount ?? exercises.length;

  final int dayNumber;
  String name;
  final int durationMinutes;
  final List<ProgramExercise> exercises;
  final bool isRest;

  /// Coach tip (DOC_6 §1.4); "" when unset.
  String note;

  /// Backend `exercise_count` when mapped from an API response (the list API
  /// may omit embedded exercises), otherwise the local list length.
  final int exerciseCount;

  ProgramDay copyWith({
    String? name,
    List<ProgramExercise>? exercises,
    bool? isRest,
    int? dayNumber,
    String? note,
    int? exerciseCount,
  }) => ProgramDay(
    dayNumber: dayNumber ?? this.dayNumber,
    name: name ?? this.name,
    durationMinutes: durationMinutes,
    exercises: exercises ?? List.from(this.exercises),
    isRest: isRest ?? this.isRest,
    note: note ?? this.note,
    // Local edits recompute unless a fresh backend count is supplied.
    exerciseCount:
        exerciseCount ?? (exercises != null ? exercises.length : this.exerciseCount),
  );
}

class ProgramExercise {
  const ProgramExercise({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameAr,
    this.thumbnailUrl = '',
    this.videoUrlMale = '',
    this.videoUrlFemale = '',
  });
  final String id;

  /// Default name (backend fallback language).
  final String name;
  final String? nameEn;
  final String? nameAr;

  /// Backend thumbnail for display (gender-matched at mapping time).
  final String thumbnailUrl;

  /// Backend demo videos for playback.
  final String videoUrlMale;
  final String videoUrlFemale;

  /// Both API-provided languages joined, e.g. "ديدليفت بالبار / Barbell Deadlift".
  String get displayName =>
      buildBilingualLabel(primary: name, arabic: nameAr, english: nameEn);
}

class LibraryExercise {
  const LibraryExercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.nameEn,
    this.nameAr,
    this.thumbnailUrl = '',
    this.videoUrlMale = '',
    this.videoUrlFemale = '',
  });
  final String id;
  final String name;
  final String muscleGroup;
  final String? nameEn;
  final String? nameAr;

  /// Backend demo media for playback/thumbnails in day views.
  final String thumbnailUrl;
  final String videoUrlMale;
  final String videoUrlFemale;

  /// Both API-provided languages joined, e.g. "ديدليفت بالبار / Barbell Deadlift".
  String get displayName =>
      buildBilingualLabel(primary: name, arabic: nameAr, english: nameEn);
}
