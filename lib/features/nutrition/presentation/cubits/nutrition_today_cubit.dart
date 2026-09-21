import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/nutrition/domain/usecases/complete_meal_log_usecase.dart';
import 'package:athletica/features/nutrition/domain/usecases/get_today_meals_usecase.dart';
import 'package:athletica/features/nutrition/domain/usecases/uncomplete_meal_log_usecase.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NutritionTodayCubit extends Cubit<NutritionTodayState> {
  NutritionTodayCubit(
    this._getTodayMeals,
    this._completeMeal,
    this._uncompleteMeal,
  ) : super(NutritionTodayInitial());

  final GetTodayMealsUseCase _getTodayMeals;
  final CompleteMealLogUseCase _completeMeal;
  final UncompleteMealLogUseCase _uncompleteMeal;

  Future<void> load() async {
    if (state is NutritionTodayLoading) return;

    emit(NutritionTodayLoading());

    final result = await _getTodayMeals();
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(NutritionTodayLoaded(data));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(NutritionTodayError(failure.message));
    }
  }

  /// Keep confirmed data visible while only the affected control is busy.
  Future<void> toggleComplete(String mealLogId, bool targetCompleted) async {
    final current = state;
    if (current is! NutritionTodayLoaded ||
        current.togglingMealLogIds.contains(mealLogId)) {
      return;
    }
    final meal = current.meals.meals
        .where((m) => m.mealLogId == mealLogId)
        .firstOrNull;
    if (meal == null || meal.completed == targetCompleted) return;
    emit(
      NutritionTodayLoaded(
        current.meals,
        togglingMealLogIds: {...current.togglingMealLogIds, mealLogId},
      ),
    );
    final result = targetCompleted
        ? await _completeMeal(mealLogId)
        : await _uncompleteMeal(mealLogId);
    if (isClosed) return;
    final latest = state;
    if (latest is! NutritionTodayLoaded) return;
    final pending = {...latest.togglingMealLogIds}..remove(mealLogId);
    switch (result) {
      case ApiSuccess(:final data):
        final updated = data.meals
            .where((m) => m.mealLogId == mealLogId)
            .firstOrNull;
        emit(
          NutritionTodayLoaded(
            updated == null ? latest.meals : latest.meals.replaceMeal(updated),
            togglingMealLogIds: pending,
            errorMessage: updated == null
                ? 'Could not confirm meal status. Please try again.'
                : null,
          ),
        );
      case ApiError(:final failure):
        emit(
          NutritionTodayLoaded(
            latest.meals,
            togglingMealLogIds: pending,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
