import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/meal_type_labels.dart';
import 'package:athletica/core/utils/nutrition_display_format.dart';
import 'package:athletica/core/widgets/nutrition/meal_completion_control.dart';
import 'package:athletica/core/widgets/nutrition/nutrition_food_list.dart';
import 'package:athletica/core/widgets/nutrition/nutrition_macros.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_cubit.dart';
import 'package:athletica/features/nutrition/presentation/views/today_meal_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.meal});
  final TodayMeal meal;
  @override
  Widget build(BuildContext context) {
    final type = labelForMealType(meal.mealType);
    final title = meal.notes.trim().isEmpty ? type : meal.notes.trim();
    void open() => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<NutritionTodayCubit>(),
          child: TodayMealDetailsView(mealLogId: meal.mealLogId),
        ),
      ),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: open,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 12.h, 0, 12.h),
                  child: Row(
                    children: [
                      Text(
                        meal.mealOrder.toString().padLeft(2, '0'),
                        style: AppTextStyles.medium13(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(width: 10.w),
                      const NutritionFoodIcon(),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTextStyles.semiBold15(
                                context,
                              ).copyWith(color: AppColors.textPrimary),
                            ),
                            if (meal.notes.trim().isNotEmpty)
                              Text(
                                type,
                                style: AppTextStyles.meduim12(
                                  context,
                                ).copyWith(color: AppColors.textSecondary),
                              ),
                            SizedBox(height: 3.h),
                            Text(
                              '${meal.foods.length} foods · ${formatNutrition(meal.totalCalories)} kcal',
                              style: AppTextStyles.meduim12(
                                context,
                              ).copyWith(color: AppColors.textSecondary),
                            ),
                            SizedBox(height: 6.h),
                            NutritionMacros(
                              protein: meal.totalProtein,
                              carbs: meal.totalCarbs,
                              fat: meal.totalFat,
                              compact: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            MealCompletionControl(mealLogId: meal.mealLogId),
            IconButton(
              tooltip: 'Open $title',
              onPressed: open,
              icon: Icon(
                Icons.chevron_right,
                size: 20.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
