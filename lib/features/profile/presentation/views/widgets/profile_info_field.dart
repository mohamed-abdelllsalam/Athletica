import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileInfoField extends StatelessWidget {
  const ProfileInfoField({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.medium14(context).copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.textTertiary.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: AppTextStyles.medium14(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
