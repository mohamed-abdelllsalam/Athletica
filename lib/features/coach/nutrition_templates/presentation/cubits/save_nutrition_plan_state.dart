sealed class SaveNutritionPlanState {}

final class SaveNutritionPlanIdle extends SaveNutritionPlanState {}

final class SaveNutritionPlanLoading extends SaveNutritionPlanState {}

final class SaveNutritionPlanSuccess extends SaveNutritionPlanState {}

final class SaveNutritionPlanError extends SaveNutritionPlanState {
  SaveNutritionPlanError(this.message);
  final String message;
}
