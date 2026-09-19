import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';

class CoachMealIngredientCard extends StatelessWidget {
  const CoachMealIngredientCard({
    super.key,
    required this.ingredient,
    required this.onRemove,
    required this.onEditGrams,
  });

  final Ingredient ingredient;
  final VoidCallback onRemove;
  final VoidCallback onEditGrams;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(ingredient.emoji, style: TextStyle(fontSize: 28.sp)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ingredient.name,
                        style: AppTextStyles.semiBold14(
                          context,
                        ).copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      '${ingredient.calories} Cal',
                      style: AppTextStyles.semiBold14(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onEditGrams,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: AppColors.primaryBlue.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ingredient.serving,
                              style: AppTextStyles.meduim11(
                                context,
                              ).copyWith(color: AppColors.primaryBlue),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.edit,
                              color: AppColors.primaryBlue,
                              size: 10.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'P:${ingredient.proteinGrams}G  C:${ingredient.carbsGrams}g  F:${ingredient.fatGrams}g',
                      style: AppTextStyles.meduim11(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 18.sp,
            ),
          ),
        ],
      ),
    );
  }
}
