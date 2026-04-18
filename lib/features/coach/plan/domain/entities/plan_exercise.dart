class PlanExercise {
  const PlanExercise({required this.id, required this.name});

  final String id;
  final String name;
}

abstract class ExercisesData {
  static const List<PlanExercise> all = [
    PlanExercise(id: 'e1', name: 'Wide-grip Lat Pulldown'),
    PlanExercise(id: 'e2', name: 'Seated Cable Rows'),
    PlanExercise(id: 'e3', name: 'Barbell Bent-Over Row'),
    PlanExercise(id: 'e4', name: 'Deadlift'),
    PlanExercise(id: 'e5', name: 'One Arm Dumbbell Row'),
    PlanExercise(id: 'e6', name: 'Incline Dumbbell Row'),
    PlanExercise(id: 'e7', name: 'T-Bar Row'),
    PlanExercise(id: 'e8', name: 'Face Pulls'),
    PlanExercise(id: 'e9', name: 'Bench Press'),
    PlanExercise(id: 'e10', name: 'Overhead Press'),
    PlanExercise(id: 'e11', name: 'Squats'),
    PlanExercise(id: 'e12', name: 'Leg Press'),
    PlanExercise(id: 'e13', name: 'Romanian Deadlift'),
    PlanExercise(id: 'e14', name: 'Dumbbell Flyes'),
    PlanExercise(id: 'e15', name: 'Tricep Pushdown'),
  ];
}
