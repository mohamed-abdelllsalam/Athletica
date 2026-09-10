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
  });

  final String id;
  final String name;
  final String category;
  final String splitType;
  final String updatedAgo;
  final int clientCount;
  final String description;
  final String iconAsset;
  final List<ProgramDay> days;

  /// Real total across all days (from the template response) — the list
  /// API exposes no per-template client count, so cards show this instead
  /// of a hardcoded zero.
  int get totalExercises => days.fold(0, (sum, d) => sum + d.exerciseCount);
}

class ProgramDay {
  ProgramDay({
    required this.dayNumber,
    required this.name,
    required this.durationMinutes,
    required this.exercises,
    this.isRest = false,
  });

  final int dayNumber;
  String name;
  final int durationMinutes;
  final List<ProgramExercise> exercises;
  final bool isRest;

  int get exerciseCount => exercises.length;

  ProgramDay copyWith({
    String? name,
    List<ProgramExercise>? exercises,
    bool? isRest,
    int? dayNumber,
  }) => ProgramDay(
    dayNumber: dayNumber ?? this.dayNumber,
    name: name ?? this.name,
    durationMinutes: durationMinutes,
    exercises: exercises ?? List.from(this.exercises),
    isRest: isRest ?? this.isRest,
  );
}

class ProgramExercise {
  const ProgramExercise({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameAr,
  });
  final String id;

  /// Default name (backend fallback language).
  final String name;
  final String? nameEn;
  final String? nameAr;

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
  });

  final String id;
  final String name;
  final String muscleGroup;
  final String? nameEn;
  final String? nameAr;

  /// Both API-provided languages joined, e.g. "ديدليفت بالبار / Barbell Deadlift".
  String get displayName =>
      buildBilingualLabel(primary: name, arabic: nameAr, english: nameEn);
}
