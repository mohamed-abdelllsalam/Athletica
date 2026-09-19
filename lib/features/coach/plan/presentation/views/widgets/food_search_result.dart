import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_item.dart';

class CoachFoodSearchResult extends StatelessWidget {
  const CoachFoodSearchResult({
    super.key,
    required this.food,
    required this.isSelected,
    required this.isInMeal,
    required this.onToggle,
  });
  final FoodItem food;
  final bool isSelected;
  final bool isInMeal;
  final VoidCallback onToggle;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Text(food.emoji, style: TextStyle(fontSize: 20.sp)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              food.displayName,
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 28.r,
              height: 28.r,
              decoration: BoxDecoration(
                color: isInMeal
                    ? AppColors.streakGreen
                    : isSelected
                    ? AppColors.primaryBlue
                    : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                isInMeal || isSelected ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
