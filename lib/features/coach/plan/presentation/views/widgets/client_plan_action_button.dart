import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachClientPlanActionButton extends StatelessWidget {
  const CoachClientPlanActionButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primaryBlue),
        foregroundColor: AppColors.primaryBlue,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      icon: Container(
        width: 20.r,
        height: 20.r,
        decoration: const BoxDecoration(
          color: AppColors.primaryBlue,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add, color: Colors.white, size: 14.sp),
      ),
      label: Text(
        label.replaceFirst('+ ', ''),
        style: AppTextStyles.meduim12(
          context,
        ).copyWith(color: AppColors.primaryBlue),
      ),
    );
  }
}
