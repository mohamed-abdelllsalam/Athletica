import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionSummaryCard extends StatelessWidget {
  const NutritionSummaryCard({
    super.key,
    required this.totalCarbs,
    required this.totalProtein,
    required this.totalFat,
    this.isLoading = false,
  });

  final num totalCarbs;
  final num totalProtein;
  final num totalFat;
  final bool isLoading;

  String _format(num value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    if (isLoading && totalCarbs == 0 && totalProtein == 0 && totalFat == 0) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition Summary',
              style: AppTextStyles.medium16(context).copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            AppShimmer(
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) SizedBox(width: 10.w),
                    Expanded(
                      child: SkeletonBox(height: 92.h, radius: 16.r),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrition Summary',
            style: AppTextStyles.medium16(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _MacroCard(
                  icon: Icons.bakery_dining,
                  label: 'Carb',
                  value: _format(totalCarbs),
                  accentColor: AppColors.carbAccent,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MacroCard(
                  icon: Icons.egg_alt,
                  label: 'Protein',
                  value: _format(totalProtein),
                  accentColor: AppColors.proteinAccent,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MacroCard(
                  icon: Icons.water_drop,
                  label: 'Fat',
                  value: _format(totalFat),
                  accentColor: AppColors.fatAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: accentColor),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.meduim11(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
           Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: AppTextStyles.semiBold14(context).copyWith(
                    color: accentColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 2.w),
              Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: Text(
                  'Gram',
                  style: AppTextStyles.semiBold10(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
