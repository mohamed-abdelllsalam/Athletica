/// Local set-tracking args for the workout session view. The daily list
/// itself comes from `GET /workout/today` (see WorkoutsSection) — no
/// hardcoded workouts remain here.
class WorkoutExercise {
  const WorkoutExercise({
    required this.name,
    required this.sets,
    required this.repsRange,
    required this.restRange,
    required this.bottomText,
  });

  final String name;
  final int sets;
  final String repsRange;
  final String restRange;
  final String bottomText;
}
