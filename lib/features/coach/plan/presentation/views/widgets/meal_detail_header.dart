import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MealDetailHeader extends StatelessWidget {
  const MealDetailHeader({
    super.key,
    required this.nameController,
    required this.nameHasError,
    required this.showDelete,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.onExit,
    required this.onDelete,
  });

  final TextEditingController nameController;
  final bool nameHasError;
  final bool showDelete;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final VoidCallback onExit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              GestureDetector(
                onTap: onExit,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 20.sp,
                ),
              ),
              const Spacer(),
              if (showDelete)
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 22.sp,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: TextField(
            controller: nameController,
            textAlign: TextAlign.center,
            style: AppTextStyles.bold24(
              context,
            ).copyWith(color: AppColors.textPrimary, fontSize: 22.sp),
            decoration: InputDecoration(
              hintText: 'Meal name',
              hintStyle: AppTextStyles.bold24(
                context,
              ).copyWith(color: AppColors.textSecondary, fontSize: 22.sp),
              errorText: nameHasError ? 'Meal name is required' : null,
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🔥', style: TextStyle(fontSize: 16.sp)),
              SizedBox(width: 6.w),
              Text(
                '$totalCalories Calories',
                style: AppTextStyles.semiBold14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
              SizedBox(width: 16.w),
              Container(width: 1, height: 16.h, color: AppColors.surfaceDark),
              SizedBox(width: 16.w),
              Text('🎯', style: TextStyle(fontSize: 16.sp)),
              SizedBox(width: 6.w),
              Text(
                'p:${totalProtein}g . c:${totalCarbs}g . f:${totalFat}g',
                style: AppTextStyles.meduim12(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Meal Details Tab ──────────────────────────────────────────────────────────
