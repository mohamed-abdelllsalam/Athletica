import 'package:athletica/features/coach/plan/domain/entities/plan_exercise.dart';

class DayWorkout {
  DayWorkout({
    required this.day,
    List<PlanExercise>? warmUp,
    List<PlanExercise>? workout,
    List<PlanExercise>? coolDown,
    this.summary = '',
  })  : warmUp = warmUp ?? [],
        workout = workout ?? [],
        coolDown = coolDown ?? [];

  final int day;
  final List<PlanExercise> warmUp;
  final List<PlanExercise> workout;
  final List<PlanExercise> coolDown;
  final String summary;

  DayWorkout copyWith({
    List<PlanExercise>? warmUp,
    List<PlanExercise>? workout,
    List<PlanExercise>? coolDown,
    String? summary,
  }) =>
      DayWorkout(
        day: day,
        warmUp: warmUp ?? List.from(this.warmUp),
        workout: workout ?? List.from(this.workout),
        coolDown: coolDown ?? List.from(this.coolDown),
        summary: summary ?? this.summary,
      );
}
