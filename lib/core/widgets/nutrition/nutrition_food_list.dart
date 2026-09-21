import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/nutrition_display_format.dart';
import 'package:athletica/core/widgets/nutrition/nutrition_card.dart';
import 'package:athletica/features/nutrition/domain/entities/meal_food.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionFoodList extends StatelessWidget {
  const NutritionFoodList({super.key, required this.foods});
  final List<MealFood> foods;
  @override
  Widget build(BuildContext context) => NutritionCard(
    child: Column(
      children: [
        if (foods.isEmpty)
          Text(
            'No foods in this meal.',
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
        for (var i = 0; i < foods.length; i++) ...[
          if (i > 0) Divider(height: 24.h, color: AppColors.surfaceDark),
          NutritionFoodRow(food: foods[i], order: i + 1),
        ],
      ],
    ),
  );
}

class NutritionFoodRow extends StatelessWidget {
  const NutritionFoodRow({super.key, required this.food, required this.order});
  final MealFood food;
  final int order;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: Text(
          order.toString().padLeft(2, '0'),
          style: AppTextStyles.medium13(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      ),
      SizedBox(width: 10.w),
      const NutritionFoodIcon(),
      SizedBox(width: 12.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    food.displayName,
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.semiBold14(
                      context,
                    ).copyWith(color: AppColors.textPrimary, height: 1.4),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${formatNutrition(food.calories)}\nkcal',
                  textAlign: TextAlign.end,
                  style: AppTextStyles.medium13(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              '${formatNutrition(food.quantity)} ${food.servingUnit} · P ${formatNutrition(food.protein)} · C ${formatNutrition(food.carbs)} · F ${formatNutrition(food.fat)}',
              style: AppTextStyles.meduim12(
                context,
              ).copyWith(color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    ],
  );
}

class NutritionFoodIcon extends StatelessWidget {
  const NutritionFoodIcon({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 48.w,
    height: 54.h,
    decoration: BoxDecoration(
      color: AppColors.cardBackgroundLight,
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Icon(
      Icons.rice_bowl_outlined,
      color: AppColors.textPrimary,
      size: 28.sp,
    ),
  );
}
