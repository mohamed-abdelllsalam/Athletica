import 'dart:async';

import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/nutrition/domain/entities/my_plan.dart';
import 'package:athletica/features/nutrition/domain/entities/nutrition_history.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';
import 'package:athletica/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:athletica/features/nutrition/domain/usecases/complete_meal_log_usecase.dart';
import 'package:athletica/features/nutrition/domain/usecases/get_today_meals_usecase.dart';
import 'package:athletica/features/nutrition/domain/usecases/uncomplete_meal_log_usecase.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_cubit.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_state.dart';
import 'package:flutter_test/flutter_test.dart';

TodayMeal _meal(String id, {bool completed = false}) => TodayMeal(
  mealLogId: id,
  mealId: 'meal-$id',
  mealType: 'Breakfast',
  mealOrder: id == 'a' ? 1 : 2,
  completed: completed,
  completedAt: completed ? DateTime.utc(2026, 9, 21, 8) : null,
  foods: const [],
);

TodayMeals _meals({bool a = false, bool b = false}) => TodayMeals(
  meals: [
    _meal('a', completed: a),
    _meal('b', completed: b),
  ],
  dayCompleted: a && b,
);

void main() {
  late _NutritionRepository repository;
  late NutritionTodayCubit cubit;

  setUp(() {
    repository = _NutritionRepository(_meals());
    cubit = NutritionTodayCubit(
      GetTodayMealsUseCase(repository),
      CompleteMealLogUseCase(repository),
      UncompleteMealLogUseCase(repository),
    );
    addTearDown(cubit.close);
  });

  group('NutritionTodayCubit', () {
    test('retains incomplete meal until server confirms completion', () async {
      await cubit.load();
      final original = cubit.state.meals;
      final request = cubit.toggleComplete('a', true);

      expect(cubit.state.meals, same(original));
      expect((cubit.state as NutritionTodayLoaded).togglingMealLogIds, {'a'});
      repository.requests['a']!.complete(ApiSuccess(_meals(a: true)));
      await request;

      expect(cubit.state.meals.meals.first.completed, isTrue);
      expect(
        cubit.state.meals.meals.first.completedAt,
        DateTime.utc(2026, 9, 21, 8),
      );
      expect((cubit.state as NutritionTodayLoaded).togglingMealLogIds, isEmpty);
      expect(repository.completeCalls, ['a']);
    });

    test('uses uncomplete endpoint and waits for confirmation', () async {
      repository.today = _meals(a: true);
      await cubit.load();
      final request = cubit.toggleComplete('a', false);
      expect(cubit.state.meals.meals.first.completed, isTrue);

      repository.requests['a']!.complete(ApiSuccess(_meals()));
      await request;

      expect(cubit.state.meals.meals.first.completed, isFalse);
      expect(cubit.state.meals.meals.first.completedAt, isNull);
      expect(repository.uncompleteCalls, ['a']);
      expect(repository.completeCalls, isEmpty);
    });

    test('ignores duplicate toggles while the same meal is pending', () async {
      await cubit.load();
      final first = cubit.toggleComplete('a', true);
      await cubit.toggleComplete('a', true);
      await cubit.toggleComplete('a', false);

      expect(repository.completeCalls, ['a']);
      expect(repository.uncompleteCalls, isEmpty);
      repository.requests['a']!.complete(ApiSuccess(_meals(a: true)));
      await first;
    });

    test(
      'preserves both changes when concurrent responses contain stale meals',
      () async {
        await cubit.load();
        final first = cubit.toggleComplete('a', true);
        final second = cubit.toggleComplete('b', true);
        expect((cubit.state as NutritionTodayLoaded).togglingMealLogIds, {
          'a',
          'b',
        });

        repository.requests['b']!.complete(ApiSuccess(_meals(b: true)));
        await second;
        expect((cubit.state as NutritionTodayLoaded).togglingMealLogIds, {'a'});
        repository.requests['a']!.complete(ApiSuccess(_meals(a: true)));
        await first;

        expect(cubit.state.meals.meals.map((meal) => meal.completed), [
          true,
          true,
        ]);
        expect((cubit.state as NutritionTodayLoaded).dayCompleted, isTrue);
        expect(
          (cubit.state as NutritionTodayLoaded).togglingMealLogIds,
          isEmpty,
        );
      },
    );

    test(
      'failure retains exact previous data and exposes an inline error',
      () async {
        await cubit.load();
        final original = cubit.state.meals;
        final request = cubit.toggleComplete('a', true);
        repository.requests['a']!.complete(
          const ApiError(NetworkFailure('Offline')),
        );
        await request;

        final state = cubit.state as NutritionTodayLoaded;
        expect(state.meals, same(original));
        expect(state.errorMessage, isNotEmpty);
        expect(state.togglingMealLogIds, isEmpty);
      },
    );

    test(
      'failure of one request preserves a concurrent confirmed change',
      () async {
        await cubit.load();
        final first = cubit.toggleComplete('a', true);
        final second = cubit.toggleComplete('b', true);
        repository.requests['b']!.complete(ApiSuccess(_meals(b: true)));
        await second;
        final confirmed = cubit.state.meals;
        repository.requests['a']!.complete(
          const ApiError(NetworkFailure('Offline')),
        );
        await first;

        expect(cubit.state.meals, same(confirmed));
        expect(cubit.state.meals.meals.map((meal) => meal.completed), [
          false,
          true,
        ]);
        expect((cubit.state as NutritionTodayLoaded).errorMessage, isNotEmpty);
      },
    );
  });
}

class _NutritionRepository implements NutritionRepository {
  _NutritionRepository(this.today);

  TodayMeals today;
  final completeCalls = <String>[];
  final uncompleteCalls = <String>[];
  final requests = <String, Completer<ApiResult<TodayMeals>>>{};

  @override
  Future<ApiResult<TodayMeals>> getTodayMeals() async => ApiSuccess(today);

  @override
  Future<ApiResult<TodayMeals>> completeMeal(String mealLogId) {
    completeCalls.add(mealLogId);
    final request = Completer<ApiResult<TodayMeals>>();
    requests[mealLogId] = request;
    return request.future;
  }

  @override
  Future<ApiResult<TodayMeals>> uncompleteMeal(String mealLogId) {
    uncompleteCalls.add(mealLogId);
    final request = Completer<ApiResult<TodayMeals>>();
    requests[mealLogId] = request;
    return request.future;
  }

  @override
  Future<ApiResult<MyPlan?>> getMyActivePlan() => throw UnimplementedError();

  @override
  Future<ApiResult<MyPlan>> getMyPlanDetails(String planId) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<List<NutritionHistoryDay>>> getHistory({
    DateTime? from,
    DateTime? to,
  }) => throw UnimplementedError();
}
