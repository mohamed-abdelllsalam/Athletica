import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/nutrition/nutrition_status.dart';
import 'package:athletica/features/home/presentation/views/widgets/meal_card.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MealSection extends StatelessWidget {
  const MealSection({super.key, required this.meals});
  final TodayMeals meals;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Today's Meals",
        style: AppTextStyles.bold20(
          context,
        ).copyWith(color: AppColors.textPrimary),
      ),
      SizedBox(height: 10.h),
      if (meals.meals.isEmpty)
        const NutritionStatus(message: 'No meals scheduled for today')
      else
        for (final meal in meals.sortedMeals)
          MealCard(key: ValueKey(meal.mealLogId), meal: meal),
    ],
  );
}
