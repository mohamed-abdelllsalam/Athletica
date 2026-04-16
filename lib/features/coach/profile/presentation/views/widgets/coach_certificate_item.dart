import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachCertificateItem extends StatelessWidget {
  const CoachCertificateItem({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52.r,
          height: 52.r,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.description_rounded,
            color: AppColors.textSecondary,
            size: 24.sp,
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
