import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';

sealed class NutritionTemplatesListState {}

final class NutritionTemplatesListInitial extends NutritionTemplatesListState {}

final class NutritionTemplatesListLoading extends NutritionTemplatesListState {}

final class NutritionTemplatesListLoaded extends NutritionTemplatesListState {
  NutritionTemplatesListLoaded(this.plans);
  final List<NutritionPlan> plans;
}

final class NutritionTemplatesListError extends NutritionTemplatesListState {
  NutritionTemplatesListError(this.message);
  final String message;
}
