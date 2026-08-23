import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/home/presentation/views/widgets/meal_section.dart';
import 'package:athletica/features/home/presentation/views/widgets/nutrition_summary_card.dart';
import 'package:athletica/features/home/presentation/views/widgets/total_nutritions_bar.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_cubit.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionsSection extends StatelessWidget {
  const NutritionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NutritionTodayCubit>()..load(),
      child: BlocBuilder<NutritionTodayCubit, NutritionTodayState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NutritionSummaryCard(
                totalCarbs: state.meals.totalCarbs,
                totalProtein: state.meals.totalProtein,
                totalFat: state.meals.totalFat,
                isLoading: state is NutritionTodayLoading,
              ),
              SizedBox(height: 24.h),
              TotalNutritionsBar(meals: state.meals),
              SizedBox(height: 24.h),
              MealSection(
                meals: state.meals.meals,
                isLoading: state is NutritionTodayLoading,
                errorMessage:
                    state is NutritionTodayError ? state.message : null,
                togglingMealLogId: state is NutritionTodayLoaded
                    ? state.togglingMealLogId
                    : null,
                onRetry: () =>
                    context.read<NutritionTodayCubit>().load(),
                onToggleComplete: (mealLogId, targetCompleted) => context
                    .read<NutritionTodayCubit>()
                    .toggleComplete(mealLogId, targetCompleted),
              ),
            ],
          );
        },
      ),
    );
  }
}
