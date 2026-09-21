import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TotalNutritionsBar extends StatelessWidget {
  const TotalNutritionsBar({super.key, required this.meals});
  final TodayMeals meals;
  @override
  Widget build(BuildContext context) {
    final segments = [
      ('Carb', meals.caloriesFromCarbs, AppColors.barCarb),
      ('Fat', meals.caloriesFromFat, AppColors.barFat),
      ('Protein', meals.caloriesFromProtein, AppColors.barProtein),
    ];
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: SizedBox(
            height: 10.h,
            width: double.infinity,
            child: meals.totalMacroCalories <= 0
                ? const ColoredBox(color: AppColors.surfaceDark)
                : Row(
                    children: [
                      for (final segment in segments)
                        if (segment.$2 > 0)
                          Expanded(
                            flex:
                                ((segment.$2 / meals.totalMacroCalories) *
                                        10000)
                                    .round()
                                    .clamp(1, 10000),
                            child: ColoredBox(
                              color: segment.$3,
                              child: const SizedBox.expand(),
                            ),
                          ),
                    ],
                  ),
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 24.w,
          runSpacing: 6.h,
          children: [
            for (final segment in segments)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 10.sp, color: segment.$3),
                  SizedBox(width: 6.w),
                  Text(
                    segment.$1,
                    style: AppTextStyles.meduim11(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
