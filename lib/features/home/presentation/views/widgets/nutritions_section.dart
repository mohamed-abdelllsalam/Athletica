import 'package:athletica/core/widgets/connection_error_view.dart';
import 'package:athletica/core/widgets/refresh_on_focus.dart';
import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/widgets/nutrition/meal_completion_control.dart';
import 'package:athletica/core/widgets/nutrition/nutrition_status.dart';
import 'package:athletica/features/home/presentation/views/widgets/meal_section.dart';
import 'package:athletica/features/home/presentation/views/widgets/nutrition_summary_card.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';
import 'package:athletica/features/nutrition/presentation/cubits/my_plan_details_cubit.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_cubit.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionsSection extends StatelessWidget {
  const NutritionsSection({super.key});
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => sl<NutritionTodayCubit>()..load()),
      BlocProvider(create: (_) => sl<MyPlanDetailsCubit>()..load()),
    ],
    child: Builder(
      builder: (context) => RefreshOnFocus(
        onRefresh: () async {
          await Future.wait([
            context.read<NutritionTodayCubit>().load(),
            context.read<MyPlanDetailsCubit>().load(),
          ]);
        },
        child: const _NutritionBody(),
      ),
    ),
  );
}

class _NutritionBody extends StatelessWidget {
  const _NutritionBody();
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: NutritionCompletionFeedback(
      child: BlocBuilder<MyPlanDetailsCubit, MyPlanDetailsState>(
        builder: (context, planState) => switch (planState) {
          MyPlanDetailsInitial() ||
          MyPlanDetailsLoading() => const NutritionLoading(),
          MyPlanDetailsNoPlan() => NutritionNoPlan(
            onRefresh: () {
              context.read<MyPlanDetailsCubit>().load();
              context.read<NutritionTodayCubit>().load();
            },
          ),
          MyPlanDetailsError(:final message, :final isConnectionError) =>
            isConnectionError
                ? ConnectionErrorView(
                    onRetry: () {
                      context.read<MyPlanDetailsCubit>().load();
                      context.read<NutritionTodayCubit>().load();
                    },
                    compact: true,
                  )
                : NutritionStatus(
                    message: message,
                    action: 'Retry',
                    onAction: () => context.read<MyPlanDetailsCubit>().load(),
                  ),
          MyPlanDetailsLoaded(:final isConnectionError) =>
            ConnectionErrorSection(
              hasError: isConnectionError,
              onRetry: () {
                context.read<MyPlanDetailsCubit>().load();
                context.read<NutritionTodayCubit>().load();
              },
              child: const _TodayContent(),
            ),
        },
      ),
    ),
  );
}

class _TodayContent extends StatelessWidget {
  const _TodayContent();
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<NutritionTodayCubit, NutritionTodayState>(
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType ||
            (previous is NutritionTodayLoaded &&
                current is NutritionTodayLoaded &&
                previous.isConnectionError != current.isConnectionError) ||
            (previous is NutritionTodayLoaded &&
                current is NutritionTodayLoaded &&
                !_sameMealPresentation(previous.meals, current.meals)),
        builder: (context, state) => switch (state) {
          NutritionTodayInitial() ||
          NutritionTodayLoading() => const NutritionLoading(),
          NutritionTodayError(:final message, :final isConnectionError) =>
            isConnectionError
                ? ConnectionErrorView(
                    onRetry: () => context.read<NutritionTodayCubit>().load(),
                    compact: true,
                  )
                : NutritionStatus(
                    message: message,
                    action: 'Retry',
                    onAction: () => context.read<NutritionTodayCubit>().load(),
                  ),
          NutritionTodayLoaded(:final isConnectionError) => Column(
            children: [
              if (isConnectionError)
                ConnectionErrorView(
                  onRetry: () => context.read<NutritionTodayCubit>().load(),
                  compact: true,
                ),
              NutritionSummaryCard(meals: state.meals),
              SizedBox(height: 16.h),
              MealSection(meals: state.meals),
            ],
          ),
        },
      );
}

bool _sameMealPresentation(TodayMeals previous, TodayMeals next) {
  if (previous.meals.length != next.meals.length) return false;
  for (var i = 0; i < previous.meals.length; i++) {
    final a = previous.meals[i];
    final b = next.meals[i];
    if (a.mealLogId != b.mealLogId ||
        a.mealId != b.mealId ||
        a.mealType != b.mealType ||
        a.mealOrder != b.mealOrder ||
        a.notes != b.notes ||
        a.foods.length != b.foods.length ||
        a.totalCalories != b.totalCalories ||
        a.totalProtein != b.totalProtein ||
        a.totalCarbs != b.totalCarbs ||
        a.totalFat != b.totalFat) {
      return false;
    }
  }
  return true;
}
