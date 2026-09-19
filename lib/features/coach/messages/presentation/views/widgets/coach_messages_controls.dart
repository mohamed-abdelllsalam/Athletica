import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachMessagesSearch extends StatelessWidget {
  const CoachMessagesSearch({
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

class CoachMessagesTab extends StatelessWidget {
  const CoachMessagesTab({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: AppTextStyles.semiBold15(context).copyWith(
          color: isActive ? AppColors.textPrimary : AppColors.primaryBlue,
        ),
      ),
    );
  }
}
