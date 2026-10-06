import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';

sealed class NutritionTodayState {
  const NutritionTodayState();

  TodayMeals get meals => TodayMeals.empty;
}

final class NutritionTodayInitial extends NutritionTodayState {}

final class NutritionTodayLoading extends NutritionTodayState {}

/// Meals are loaded; [togglingMealLogId] marks an in-flight complete /
/// uncomplete request for that meal.
final class NutritionTodayLoaded extends NutritionTodayState {
  const NutritionTodayLoaded(
    this.meals, {
    this.togglingMealLogIds = const {},
    this.errorMessage,
    this.isConnectionError = false,
  });

  @override
  final TodayMeals meals;
  final Set<String> togglingMealLogIds;
  String? get togglingMealLogId => togglingMealLogIds.firstOrNull;
  final String? errorMessage;
  final bool isConnectionError;

  /// True when every meal is completed and there is at least one meal.
  bool get dayCompleted => meals.dayCompleted == true;
}

final class NutritionTodayError extends NutritionTodayState {
  const NutritionTodayError(this.message, {this.isConnectionError = false});
  final bool isConnectionError;

  final String message;
}
