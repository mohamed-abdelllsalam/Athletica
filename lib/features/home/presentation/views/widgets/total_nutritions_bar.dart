import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TotalNutritionsBar extends StatelessWidget {
  const TotalNutritionsBar({super.key});

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

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.r),
      child: SizedBox(
        height: 14.h,
        child: Row(
          children: const [
            _BarSegment(flex: 40, color: AppColors.barCarb),
            _BarSegment(flex: 20, color: AppColors.barFat),
            _BarSegment(flex: 25, color: AppColors.barProtein),
            _BarSegment(flex: 15, color: AppColors.barExtraMeals),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 16.w,
      runSpacing: 6.h,
      children: const [
        _LegendItem(label: 'Carb', emoji: '🔥', color: AppColors.barCarb),
        _LegendItem(label: 'Fat', emoji: '🔥', color: AppColors.barFat),
        _LegendItem(
          label: 'Protein',
          emoji: '🔥',
          color: AppColors.barProtein,
        ),
        _LegendItem(
          label: 'Extra meals',
          emoji: '🔥',
          color: AppColors.barExtraMeals,
        ),
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
    required this.emoji,
    required this.color,
  });

  final String label;
  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.meduim11(context).copyWith(
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
