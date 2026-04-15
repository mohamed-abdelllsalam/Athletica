import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionSummaryCard extends StatelessWidget {
  const NutritionSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                  icon: '🍖',
                  label: 'Carb',
                  value: '110',
                  targetValue: '200',
                  accentColor: AppColors.carbAccent,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MacroCard(
                  icon: '🥩',
                  label: 'Protein',
                  value: '67',
                  targetValue: '80',
                  accentColor: AppColors.proteinAccent,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MacroCard(
                  icon: '🧈',
                  label: 'Fat',
                  value: '85',
                  targetValue: '110',
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
    required this.targetValue,
    required this.accentColor,
  });

  final String icon;
  final String label;
  final String value;
  final String targetValue;
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
              Text(icon, style: TextStyle(fontSize: 16.sp)),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.meduim12(context).copyWith(
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
              Text(
                value,
                style: AppTextStyles.bold20(context).copyWith(
                  color: accentColor,
                ),
              ),
              SizedBox(width: 4.w),
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Text(
                  'Gram',
                  style: AppTextStyles.meduim11(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Container(
                width: 6.r,
                height: 6.r,
                decoration: BoxDecoration(
                  color: AppColors.streakGreen,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  'Target $targetValue Gram',
                  style: AppTextStyles.semiBold10(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
