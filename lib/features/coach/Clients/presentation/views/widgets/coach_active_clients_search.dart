import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachActiveClientsSearch extends StatelessWidget {
  const CoachActiveClientsSearch({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.medium14(
          context,
        ).copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }
}
