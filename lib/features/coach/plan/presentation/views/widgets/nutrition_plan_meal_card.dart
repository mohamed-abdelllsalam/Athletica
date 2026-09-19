import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachNutritionPlanMealCard extends StatelessWidget {
  const CoachNutritionPlanMealCard({
    super.key,
    required this.meal,
    required this.onTap,
  });

  final Meal meal;
  final VoidCallback onTap;

  static IconData _iconForType(String type) => switch (type) {
    'Breakfast' => Icons.wb_sunny_outlined,
    'Lunch' => Icons.restaurant_outlined,
    'Snack' => Icons.cake_outlined,
    'Dinner' => Icons.nightlight_outlined,
    _ => Icons.local_cafe_outlined,
  };

  static Color _bgColorForType(String type) => switch (type) {
    'Breakfast' => const Color(0xFF2C6E3A),
    'Lunch' => const Color(0xFF1C5C2A),
    'Snack' => const Color(0xFF3D2A7A),
    'Dinner' => const Color(0xFF2A1C5A),
    _ => const Color(0xFF1C2A5A),
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: _bgColorForType(meal.type),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                _iconForType(meal.type),
                color: Colors.white,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: AppTextStyles.semiBold14(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${meal.calories} CAL . ${meal.proteinGrams}G Protein',
                    style: AppTextStyles.meduim12(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}
