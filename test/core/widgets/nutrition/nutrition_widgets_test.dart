import 'dart:async';

import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/widgets/nutrition/meal_completion_control.dart';
import 'package:athletica/core/widgets/nutrition/nutrition_food_list.dart';
import 'package:athletica/features/home/presentation/views/widgets/meal_card.dart';
import 'package:athletica/features/home/presentation/views/widgets/nutrition_summary_card.dart';
import 'package:athletica/features/nutrition/domain/entities/meal_food.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';
import 'package:athletica/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:athletica/features/nutrition/domain/usecases/complete_meal_log_usecase.dart';
import 'package:athletica/features/nutrition/domain/usecases/get_today_meals_usecase.dart';
import 'package:athletica/features/nutrition/domain/usecases/uncomplete_meal_log_usecase.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_cubit.dart';
import 'package:athletica/features/nutrition/presentation/views/today_meal_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const _meal = TodayMeal(
  mealLogId: 'a',
  mealId: 'meal',
  mealType: 'breakfast',
  mealOrder: 1,
  completed: false,
  foods: [],
);
const _otherMeal = TodayMeal(
  mealLogId: 'b',
  mealId: 'meal-b',
  mealType: 'lunch',
  mealOrder: 2,
  completed: false,
  foods: [],
);

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  NutritionTodayCubit? cubit,
  double width = 375,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: cubit == null
            ? Scaffold(body: SingleChildScrollView(child: child))
            : BlocProvider.value(
                value: cubit,
                child: Scaffold(
                  body: NutritionCompletionFeedback(
                    child: SingleChildScrollView(child: child),
                  ),
                ),
              ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  late _Repository repository;
  late NutritionTodayCubit cubit;
  setUp(() async {
    repository = _Repository();
    cubit = NutritionTodayCubit(
      GetTodayMealsUseCase(repository),
      CompleteMealLogUseCase(repository),
      UncompleteMealLogUseCase(repository),
    );
    await cubit.load();
    addTearDown(cubit.close);
  });

  testWidgets(
    'meal completion control does not navigate and only disables its own meal',
    (tester) async {
      await _pump(
        tester,
        const Column(
          children: [
            MealCard(meal: _meal),
            MealCard(meal: _otherMeal),
          ],
        ),
        cubit: cubit,
      );
      await tester.tap(find.byTooltip('Mark Meal Complete').first);
      await tester.pump();

      expect(find.byType(TodayMealDetailsView), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final buttons = tester
          .widgetList<IconButton>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is IconButton &&
                  widget.tooltip == 'Mark Meal Complete',
            ),
          )
          .toList();
      expect(buttons.first.onPressed, isNull);
      expect(buttons.last.onPressed, isNotNull);
      repository.request.complete(
        const ApiError(NetworkFailure('Could not update meal')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Could not update meal'), findsOneWidget);
      expect(find.byType(MealCard), findsNWidgets(2));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets('meal card body opens dedicated details screen', (tester) async {
    await _pump(tester, const MealCard(meal: _meal), cubit: cubit);
    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();
    expect(find.byType(TodayMealDetailsView), findsOneWidget);
    expect(find.text('Not completed'), findsOneWidget);
    expect(find.text('Mark Meal Complete'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long bilingual food names wrap at narrow width and large text', (
    tester,
  ) async {
    const food = MealFood(
      foodId: 'food',
      name: 'Fallback name',
      nameAr: 'صدور دجاج مشوية مع الأرز والخضروات الطازجة',
      nameEn: 'Grilled chicken breast with rice and fresh vegetables',
      quantity: 250,
      servingUnit: 'g',
      calories: 325,
      protein: 7,
      carbs: 70,
      fat: 1,
    );
    await _pump(
      tester,
      const NutritionFoodList(foods: [food]),
      width: 320,
      textScale: 1.5,
    );
    expect(find.text(food.displayName), findsOneWidget);
    expect(find.byIcon(Icons.rice_bowl_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('food row uses catalog name when translations are missing', (
    tester,
  ) async {
    const food = MealFood(
      foodId: 'food',
      name: 'Catalog food',
      quantity: 100,
      servingUnit: 'g',
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
    );
    await _pump(
      tester,
      const NutritionFoodList(foods: [food]),
      width: 320,
      textScale: 1.5,
    );
    expect(find.text('Catalog food'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'summary renders zero macros and empty progress without layout errors',
    (tester) async {
      await _pump(
        tester,
        const NutritionSummaryCard(meals: TodayMeals.empty),
        width: 320,
        textScale: 1.5,
      );
      expect(find.text('0 of 0 meals completed'), findsOneWidget);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        0,
      );
      expect(find.text('0 g'), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    },
  );
}

class _Repository implements NutritionRepository {
  final request = Completer<ApiResult<TodayMeals>>();
  @override
  Future<ApiResult<TodayMeals>> getTodayMeals() async => const ApiSuccess(
    TodayMeals(meals: [_meal, _otherMeal], dayCompleted: false),
  );
  @override
  Future<ApiResult<TodayMeals>> completeMeal(String mealLogId) =>
      request.future;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
