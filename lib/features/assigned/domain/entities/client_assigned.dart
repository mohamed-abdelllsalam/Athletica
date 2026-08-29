/// Client's assigned plans from `GET /client/assigned`.
///
/// Both [workout] and [nutrition] can be independently `null`.
class ClientAssigned {
  const ClientAssigned({
    this.workout,
    this.nutrition,
  });

  final AssignedWorkout? workout;
  final AssignedNutrition? nutrition;

  bool get hasWorkout => workout != null;
  bool get hasNutrition => nutrition != null;
  bool get hasAny => hasWorkout || hasNutrition;
  bool get hasBoth => hasWorkout && hasNutrition;
  bool get hasNone => !hasWorkout && !hasNutrition;
}

class AssignedWorkout {
  const AssignedWorkout({
    required this.id,
    required this.title,
    this.description,
    required this.isActive,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
}

class AssignedNutrition {
  const AssignedNutrition({
    required this.id,
    required this.title,
    this.description,
    required this.isActive,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
}
