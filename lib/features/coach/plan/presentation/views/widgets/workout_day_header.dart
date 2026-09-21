import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';

class WorkoutDayHeader extends StatelessWidget {
  const WorkoutDayHeader({
    super.key,
    required this.day,
    required this.isCreateMode,
    required this.nameController,
    required this.nameHasError,
    required this.exerciseCount,
    required this.onExit,
    required this.onDelete,
  });

  final ProgramDay day;
  final bool isCreateMode;
  final TextEditingController nameController;
  final bool nameHasError;
  final int exerciseCount;
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
              if (isCreateMode)
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: const Color(0xFFFF5252),
                      size: 16.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Day ${day.dayNumber}',
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 2.h),
        if (isCreateMode)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              controller: nameController,
              textAlign: TextAlign.center,
              style: AppTextStyles.bold24(
                context,
              ).copyWith(color: AppColors.textPrimary, fontSize: 22.sp),
              decoration: InputDecoration(
                hintText: 'Day name',
                hintStyle: AppTextStyles.bold24(
                  context,
                ).copyWith(color: AppColors.textSecondary, fontSize: 22.sp),
                errorText: nameHasError ? 'Required' : null,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          )
        else
          Text(
            day.name,
            style: AppTextStyles.bold24(
              context,
            ).copyWith(color: AppColors.textPrimary, fontSize: 22.sp),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: AppColors.textSecondary,
                size: 14.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                '$exerciseCount Exercises',
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
