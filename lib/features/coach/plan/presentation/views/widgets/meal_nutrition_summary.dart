import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachMealNutritionSummary extends StatelessWidget {
  const CoachMealNutritionSummary({
    super.key,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalFat,
    required this.totalCarbs,
  });
  final int totalCalories;
  final int totalProtein;
  final int totalFat;
  final int totalCarbs;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrition Summary',
            style: AppTextStyles.semiBold14(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroStat(
                value: '$totalCalories',
                label: 'Calories',
                color: AppColors.primaryBlue,
              ),
              _MacroStat(
                value: '${totalProtein}g',
                label: 'Protein',
                color: const Color(0xFF4CAF50),
              ),
              _MacroStat(
                value: '${totalFat}g',
                label: 'Fat',
                color: const Color(0xFFFFB300),
              ),
              _MacroStat(
                value: '${totalCarbs}g',
                label: 'Carbs',
                color: const Color(0xFF42A5F5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroStat extends StatelessWidget {
  const _MacroStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bold24(
            context,
          ).copyWith(color: color, fontSize: 18.sp),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: AppTextStyles.meduim12(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
