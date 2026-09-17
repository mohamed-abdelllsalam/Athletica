import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NutritionPlansSearchBar extends StatelessWidget {
  const NutritionPlansSearchBar({
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

class NutritionPlansCreateButton extends StatelessWidget {
  const NutritionPlansCreateButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
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

class NutritionPlansCategoryChip extends StatelessWidget {
  const NutritionPlansCategoryChip({
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
          color: isSelected ? AppColors.primaryBlue : AppColors.cardBackground,
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

class NutritionPlanListCard extends StatelessWidget {
  const NutritionPlanListCard({
    super.key,
    required this.plan,
    required this.iconColor,
    required this.onTap,
  });

  final NutritionPlan plan;
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
              child: SvgPicture.asset(plan.iconAsset, fit: BoxFit.contain),
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
                          plan.name.isEmpty ? 'Unnamed Plan' : plan.name,
                          style: AppTextStyles.semiBold14(
                            context,
                          ).copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _CategoryBadge(category: plan.category),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_outlined,
                        color: AppColors.textSecondary,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${plan.calories} kcal  •  ${plan.proteinGrams}g protein',
                        style: AppTextStyles.meduim12(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppColors.textSecondary,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        plan.updatedAgo,
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
    'Fat loss' => const Color(0xFF7B4FE8),
    'Muscle Gain' => const Color(0xFF3D6BC2),
    'Vegan' => const Color(0xFF2E8A4A),
    'Custom' => const Color(0xFFB22A4A),
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
