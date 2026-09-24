import 'package:athletica/core/widgets/refresh_on_focus.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/meal_type_labels.dart';
import 'package:athletica/core/widgets/nutrition/meal_completion_control.dart';
import 'package:athletica/core/widgets/nutrition/nutrition_card.dart';
import 'package:athletica/core/widgets/nutrition/nutrition_food_list.dart';
import 'package:athletica/core/widgets/nutrition/nutrition_macros.dart';
import 'package:athletica/core/widgets/nutrition/nutrition_status.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_cubit.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TodayMealDetailsView extends StatelessWidget {
  const TodayMealDetailsView({super.key, required this.mealLogId});
  final String mealLogId;
  @override
  Widget build(BuildContext context) => RefreshOnFocus(
    onRefresh: () => context.read<NutritionTodayCubit>().load(),
    child: _TodayMealDetailsContent(mealLogId: mealLogId),
  );
}

class _TodayMealDetailsContent extends StatelessWidget {
  const _TodayMealDetailsContent({required this.mealLogId});
  final String mealLogId;
  @override
  Widget build(BuildContext context) {
    final state = context.watch<NutritionTodayCubit>().state;
    final meal = state.meals.meals
        .where((m) => m.mealLogId == mealLogId)
        .firstOrNull;
    if (meal == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const NutritionAppBar(title: 'Meal'),
              if (state is NutritionTodayLoading)
                const NutritionLoading()
              else
                NutritionStatus(
                  message: state is NutritionTodayError
                      ? state.message
                      : 'This meal is no longer available.',
                ),
            ],
          ),
        ),
      );
    }
    final type = labelForMealType(meal.mealType);
    final title = meal.notes.trim().isEmpty ? type : meal.notes.trim();
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: NutritionCompletionFeedback(
          child: Column(
            children: [
              NutritionAppBar(
                title: title,
                trailing:
                    BlocSelector<
                      NutritionTodayCubit,
                      NutritionTodayState,
                      bool
                    >(
                      selector: (state) =>
                          state.meals.meals
                              .where((m) => m.mealLogId == mealLogId)
                              .firstOrNull
                              ?.completed ??
                          false,
                      builder: (context, completed) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: completed
                                ? AppColors.primaryPurple
                                : AppColors.textTertiary,
                          ),
                        ),
                        child: Text(
                          completed ? 'Completed' : 'Not completed',
                          style: AppTextStyles.meduim12(
                            context,
                          ).copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      _MealOverview(meal: meal),
                      SizedBox(height: 16.h),
                      NutritionFoodList(foods: meal.foods),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.r),
                child: MealCompletionControl(mealLogId: mealLogId, wide: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealOverview extends StatelessWidget {
  const _MealOverview({required this.meal});
  final TodayMeal meal;
  @override
  Widget build(BuildContext context) => NutritionCard(
    outlined: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Meal",
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.primaryPurple),
        ),
        SizedBox(height: 6.h),
        NutritionCalories(calories: meal.totalCalories),
        Text(
          '${meal.foods.length} foods',
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        if (meal.notes.trim().isNotEmpty) ...[
          SizedBox(height: 6.h),
          Text(
            labelForMealType(meal.mealType),
            style: AppTextStyles.medium13(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
        ],
        SizedBox(height: 20.h),
        NutritionMacros(
          protein: meal.totalProtein,
          carbs: meal.totalCarbs,
          fat: meal.totalFat,
        ),
      ],
    ),
  );
}
