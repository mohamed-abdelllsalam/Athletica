import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorkoutPlansSearchBar extends StatelessWidget {
  const WorkoutPlansSearchBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
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
          hintText: hint,
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
    );
  }
}

class WorkoutPlansCreateButton extends StatelessWidget {
  const WorkoutPlansCreateButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.buttonColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.add, color: Colors.white, size: 18.sp),
            SizedBox(width: 4.w),
            Text(
              'Create New Plan',
              style: AppTextStyles.meduim12(
                context,
              ).copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutPlansCategoryChip extends StatelessWidget {
  const WorkoutPlansCategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonColor : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.meduim12(context).copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class WorkoutPlanListCard extends StatelessWidget {
  const WorkoutPlanListCard({
    super.key,
    required this.program,
    required this.iconColor,
    required this.onTap,
  });

  final WorkoutProgram program;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60.r,
              height: 60.r,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: SvgPicture.asset(program.iconAsset, fit: BoxFit.contain),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          program.name.isEmpty ? 'Unnamed Plan' : program.name,
                          style: AppTextStyles.semiBold14(
                            context,
                          ).copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _CategoryBadge(category: program.category),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.textSecondary,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        program.splitType,
                        style: AppTextStyles.meduim12(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                      Text(
                        '  •  ',
                        style: AppTextStyles.meduim12(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                      Expanded(
                        child: Text(
                          program.updatedAgo,
                          style: AppTextStyles.meduim12(
                            context,
                          ).copyWith(color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        color: AppColors.textSecondary,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${program.totalExercises} Exercises',
                        style: AppTextStyles.meduim12(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final String category;

  Color get _color => switch (category) {
    'Strength' => const Color(0xFF7B4FE8),
    'Fat loss' => const Color(0xFF7B4FE8),
    'Boxing' => const Color(0xFFD4752A),
    'Mobility' => const Color(0xFF2E6DB4),
    'Custom' => const Color(0xFFB22A4A),
    'Vegan' => const Color(0xFF2E8A4A),
    _ => AppColors.primaryBlue,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        category,
        style: AppTextStyles.semiBold10(context).copyWith(color: _color),
      ),
    );
  }
}
