import 'package:athletica/features/coach/plan/domain/entities/plan_exercise.dart';

class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.exercises,
  });

  final String id;
  final String name;
  final List<PlanExercise> exercises;
}

abstract class WorkoutPlansData {
  static final List<WorkoutPlan> plans = const [
    WorkoutPlan(
      id: 'p1',
      name: 'Push',
      exercises: [
        PlanExercise(id: 'e9', name: 'Bench Press'),
        PlanExercise(id: 'e10', name: 'Overhead Press'),
        PlanExercise(id: 'e14', name: 'Dumbbell Flyes'),
        PlanExercise(id: 'e15', name: 'Tricep Pushdown'),
      ],
    ),
    WorkoutPlan(
      id: 'p2',
      name: 'Pull',
      exercises: [
        PlanExercise(id: 'e1', name: 'Wide-grip Lat Pulldown'),
        PlanExercise(id: 'e2', name: 'Seated Cable Rows'),
        PlanExercise(id: 'e3', name: 'Barbell Bent-Over Row'),
        PlanExercise(id: 'e4', name: 'Deadlift'),
        PlanExercise(id: 'e5', name: 'One Arm Dumbbell Row'),
        PlanExercise(id: 'e6', name: 'Incline Dumbbell Row'),
      ],
    ),
    WorkoutPlan(
      id: 'p3',
      name: 'UPPER',
      exercises: [
        PlanExercise(id: 'e9', name: 'Bench Press'),
        PlanExercise(id: 'e1', name: 'Wide-grip Lat Pulldown'),
        PlanExercise(id: 'e10', name: 'Overhead Press'),
        PlanExercise(id: 'e2', name: 'Seated Cable Rows'),
      ],
    ),
    WorkoutPlan(
      id: 'p4',
      name: 'Lower',
      exercises: [
        PlanExercise(id: 'e11', name: 'Squats'),
        PlanExercise(id: 'e12', name: 'Leg Press'),
        PlanExercise(id: 'e13', name: 'Romanian Deadlift'),
        PlanExercise(id: 'e4', name: 'Deadlift'),
      ],
    ),
    WorkoutPlan(
      id: 'p5',
      name: 'legs',
      exercises: [
        PlanExercise(id: 'e11', name: 'Squats'),
        PlanExercise(id: 'e12', name: 'Leg Press'),
        PlanExercise(id: 'e13', name: 'Romanian Deadlift'),
      ],
    ),
  ];
}
