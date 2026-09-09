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
}

class ProgramDay {
  ProgramDay({
    required this.dayNumber,
    required this.name,
    required this.durationMinutes,
    required this.exercises,
  });

  final int dayNumber;
  String name;
  final int durationMinutes;
  final List<ProgramExercise> exercises;

  int get exerciseCount => exercises.length;

  ProgramDay copyWith({String? name, List<ProgramExercise>? exercises}) =>
      ProgramDay(
        dayNumber: dayNumber,
        name: name ?? this.name,
        durationMinutes: durationMinutes,
        exercises: exercises ?? List.from(this.exercises),
      );
}

class ProgramExercise {
  const ProgramExercise({required this.id, required this.name});
  final String id;
  final String name;
}

class LibraryExercise {
  const LibraryExercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
  });

  final String id;
  final String name;
  final String muscleGroup;
}
