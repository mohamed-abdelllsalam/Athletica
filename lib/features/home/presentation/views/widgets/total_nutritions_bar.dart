import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TotalNutritionsBar extends StatelessWidget {
  const TotalNutritionsBar({super.key, required this.meals});

  final TodayMeals meals;

  Widget _buildProgressBar() {
    final total = meals.totalMacroCalories;
    if (total <= 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: SizedBox(
          height: 14.h,
          child: Row(
            children: const [
              Expanded(child: ColoredBox(color: AppColors.surfaceDark)),
            ],
          ),
        ),
      );
    }

    int share(num macroCalories) =>
        ((macroCalories / total) * 100).round().clamp(1, 98);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6.r),
      child: SizedBox(
        height: 14.h,
        child: Row(
          children: [
            _BarSegment(
              flex: share(meals.caloriesFromCarbs),
              color: AppColors.barCarb,
            ),
            _BarSegment(
              flex: share(meals.caloriesFromFat),
              color: AppColors.barFat,
            ),
            _BarSegment(
              flex: share(meals.caloriesFromProtein),
              color: AppColors.barProtein,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Nutrition's",
            style: AppTextStyles.medium16(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          _buildProgressBar(),
          SizedBox(height: 10.h),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 16.w,
      runSpacing: 6.h,
      children: [
        _LegendItem(label: 'Carb', value: meals.totalCarbs, color: AppColors.barCarb),
        _LegendItem(label: 'Fat', value: meals.totalFat, color: AppColors.barFat),
        _LegendItem(
            label: 'Protein', value: meals.totalProtein, color: AppColors.barProtein),
      ],
    );
  }
}

class _BarSegment extends StatelessWidget {
  const _BarSegment({
    required this.flex,
    required this.color,
  });

  final int flex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(color: color),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final num value;
  final Color color;

  String get _formatted =>
      value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label $_formatted g',
            style: AppTextStyles.meduim11(context).copyWith(
              color: AppColors.textPrimary,
            )),
        SizedBox(width: 4.w),
        Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
