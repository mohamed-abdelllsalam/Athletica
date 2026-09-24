import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/nutrition/nutrition_card.dart';
import 'package:athletica/core/widgets/nutrition/nutrition_macros.dart';
import 'package:athletica/features/home/presentation/views/widgets/total_nutritions_bar.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_cubit.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_state.dart';
import 'package:athletica/features/nutrition/presentation/views/my_plan_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionSummaryCard extends StatelessWidget {
  const NutritionSummaryCard({super.key, required this.meals});
  final TodayMeals meals;
  @override
  Widget build(BuildContext context) => NutritionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Today's Nutrition",
                style: AppTextStyles.semiBold15(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, MyPlanDetailsView.routeName),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryPurple,
                minimumSize: Size(
                  48.w.clamp(48, double.infinity),
                  48.h.clamp(48, double.infinity),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('View Plan'),
                  Icon(Icons.chevron_right, size: 18.sp),
                ],
              ),
            ),
          ],
        ),
        NutritionCalories(calories: meals.totalCalories, large: true),
        SizedBox(height: 6.h),
        BlocSelector<
          NutritionTodayCubit,
          NutritionTodayState,
          ({int completed, int total})
        >(
          selector: (state) => (
            completed: state.meals.completedMealCount,
            total: state.meals.meals.length,
          ),
          builder: (context, progress) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${progress.completed} of ${progress.total} meals completed',
                style: AppTextStyles.medium13(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: 8.h),
              LinearProgressIndicator(
                value: progress.total == 0
                    ? 0
                    : progress.completed / progress.total,
                minHeight: 8.h,
                borderRadius: BorderRadius.circular(6.r),
                backgroundColor: AppColors.surfaceDark,
                color: AppColors.primaryPurple,
                semanticsLabel:
                    '${progress.completed} of ${progress.total} meals completed',
              ),
            ],
          ),
        ),
        SizedBox(height: 18.h),
        NutritionMacros(
          protein: meals.totalProtein,
          carbs: meals.totalCarbs,
          fat: meals.totalFat,
          fullLabels: true,
        ),
        SizedBox(height: 16.h),
        TotalNutritionsBar(meals: meals),
      ],
    ),
  );
}
