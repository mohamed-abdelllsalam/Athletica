import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachExerciseSearchHeader extends StatelessWidget {
  const CoachExerciseSearchHeader({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onBack,
    required this.onClear,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onBack;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _RoundedIconButton(icon: Icons.arrow_back_ios_new, onTap: onBack),
          SizedBox(width: 10.w),
          Expanded(
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(10.r),
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
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          _RoundedIconButton(icon: Icons.delete_outline, onTap: onClear),
        ],
      ),
    );
  }
}

class _RoundedIconButton extends StatelessWidget {
  const _RoundedIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }
}
