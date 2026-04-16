import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachProfileInfoRow extends StatelessWidget {
  const CoachProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 14.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: AppTextStyles.regular13(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}
