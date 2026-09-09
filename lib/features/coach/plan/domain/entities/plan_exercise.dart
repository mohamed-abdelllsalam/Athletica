/// Selection return type for the exercise search picker. Instances are
/// mapped from `GET /workout/exercises` results (real API ids) — no
/// hardcoded catalog remains here.
class PlanExercise {
  const PlanExercise({required this.id, required this.name});

  final String id;
  final String name;
}
