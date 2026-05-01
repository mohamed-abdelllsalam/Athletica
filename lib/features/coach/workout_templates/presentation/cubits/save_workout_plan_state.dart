sealed class SaveWorkoutPlanState {}

final class SaveWorkoutPlanIdle extends SaveWorkoutPlanState {}

final class SaveWorkoutPlanLoading extends SaveWorkoutPlanState {}

final class SaveWorkoutPlanSuccess extends SaveWorkoutPlanState {}

final class SaveWorkoutPlanError extends SaveWorkoutPlanState {
  SaveWorkoutPlanError(this.message);
  final String message;
}
