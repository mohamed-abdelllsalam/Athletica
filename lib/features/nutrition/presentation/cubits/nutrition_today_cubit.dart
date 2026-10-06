import 'package:athletica/core/errors/failures.dart';
import 'dart:async';
import 'package:athletica/core/usecases/watch_completion_changes_usecase.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';
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
    this._uncompleteMeal, [
    WatchCompletionChangesUseCase? changes,
  ]) : super(NutritionTodayInitial()) {
    _subscription = changes?.call().listen((_) => load());
  }

  final GetTodayMealsUseCase _getTodayMeals;
  final CompleteMealLogUseCase _completeMeal;
  final UncompleteMealLogUseCase _uncompleteMeal;

  StreamSubscription<void>? _subscription;
  bool _reloadRequested = false;
  bool _loadInProgress = false;

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }

  Future<void> load() async {
    if (isClosed) return;
    final current = state;
    if (current is NutritionTodayLoaded &&
        current.togglingMealLogIds.isNotEmpty) {
      return;
    }
    if (_loadInProgress) {
      _reloadRequested = true;
      return;
    }

    _loadInProgress = true;
    if (current is! NutritionTodayLoaded) emit(NutritionTodayLoading());

    try {
      final result = await _getTodayMeals();
      if (isClosed) return;
      switch (result) {
        case ApiSuccess(:final data):
          emit(NutritionTodayLoaded(data));
        case ApiError(:final failure):
          emit(
            current is NutritionTodayLoaded
                ? NutritionTodayLoaded(
                    current.meals,
                    errorMessage: failure.message,
                    isConnectionError: failure is NetworkFailure,
                  )
                : NutritionTodayError(
                    failure.message,
                    isConnectionError: failure is NetworkFailure,
                  ),
          );
      }
    } finally {
      _loadInProgress = false;
      if (_reloadRequested && !isClosed) {
        _reloadRequested = false;
        await load();
      }
    }
  }

  /// Keep confirmed data visible while only the affected control is busy.
  Future<void> toggleComplete(String mealLogId, bool targetCompleted) async {
    final current = state;
    if (current is! NutritionTodayLoaded ||
        _loadInProgress ||
        current.togglingMealLogIds.isNotEmpty) {
      return;
    }
    final meal = current.meals.meals
        .where((m) => m.mealLogId == mealLogId)
        .firstOrNull;
    if (mealLogId.isEmpty ||
        meal == null ||
        meal.completed == targetCompleted) {
      return;
    }
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
            updated == null
                ? latest.meals
                : TodayMeals(
                    meals: latest.meals.replaceMeal(updated).meals,
                    dayCompleted: data.dayCompleted,
                  ),
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
            isConnectionError: failure is NetworkFailure,
          ),
        );
    }
  }
}
