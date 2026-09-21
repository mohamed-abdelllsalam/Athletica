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
    child: const _NutritionBody(),
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
          MyPlanDetailsError(:final message) => NutritionStatus(
            message: message,
            action: 'Retry',
            onAction: () => context.read<MyPlanDetailsCubit>().load(),
          ),
          MyPlanDetailsLoaded() => const _TodayContent(),
        },
      ),
    ),
  );
}

class _TodayContent extends StatelessWidget {
  const _TodayContent();
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<NutritionTodayCubit, NutritionTodayState>(
    buildWhen: (previous, next) => previous.runtimeType != next.runtimeType,
    builder: (context, state) => switch (state) {
      NutritionTodayInitial() ||
      NutritionTodayLoading() => const NutritionLoading(),
      NutritionTodayError(:final message) => NutritionStatus(
        message: message,
        action: 'Retry',
        onAction: () => context.read<NutritionTodayCubit>().load(),
      ),
      NutritionTodayLoaded() => Column(
        children: [
          BlocSelector<NutritionTodayCubit, NutritionTodayState, TodayMeals>(
            selector: (state) => state.meals,
            builder: (context, meals) => NutritionSummaryCard(meals: meals),
          ),
          SizedBox(height: 16.h),
          BlocSelector<NutritionTodayCubit, NutritionTodayState, TodayMeals>(
            selector: (state) => state.meals,
            builder: (context, meals) => MealSection(meals: meals),
          ),
        ],
      ),
    },
  );
}
