import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';
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
        emit(NutritionTodayLoaded(data));
      case ApiError(:final failure):
        emit(NutritionTodayError(failure.message));
    }
  }

  /// Optimistically flips the meal, then confirms with the API. Reverts on
  /// failure.
  Future<void> toggleComplete(String mealLogId, bool targetCompleted) async {
    final current = state;
    if (current is! NutritionTodayLoaded) return;
    if (current.togglingMealLogId != null) return;

    emit(NutritionTodayLoaded(
      _withCompletion(current.meals, mealLogId, targetCompleted),
      togglingMealLogId: mealLogId,
    ));

    final result = targetCompleted
        ? await _completeMeal(mealLogId)
        : await _uncompleteMeal(mealLogId);

    switch (result) {
      case ApiSuccess(:final data):
        emit(NutritionTodayLoaded(data));
      case ApiError(:final failure):
        emit(NutritionTodayLoaded(
          _withCompletion(current.meals, mealLogId, !targetCompleted),
        ));
        emit(NutritionTodayError(failure.message));
    }
  }

  TodayMeals _withCompletion(
    TodayMeals meals,
    String mealLogId,
    bool completed,
  ) {
    final updated = meals.meals
        .map((m) => m.mealLogId == mealLogId
            ? TodayMeal(
                mealLogId: m.mealLogId,
                mealId: m.mealId,
                mealType: m.mealType,
                mealOrder: m.mealOrder,
                notes: m.notes,
                completed: completed,
                completedAt: completed ? DateTime.now() : null,
                foods: m.foods,
              )
            : m)
        .toList();
    return TodayMeals(meals: updated, dayCompleted: meals.dayCompleted);
  }
}
