import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachNutritionEditorDayCounter extends StatelessWidget {
  const CoachNutritionEditorDayCounter({
    super.key,
    required this.day,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int day;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Text(
            'Day',
            style: AppTextStyles.semiBold14(
              context,
            ).copyWith(color: Colors.white),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onDecrement,
            child: const Icon(Icons.remove, color: Colors.white),
          ),
          SizedBox(width: 16.w),
          Text(
            '$day',
            style: AppTextStyles.semiBold14(
              context,
            ).copyWith(color: Colors.white),
          ),
          SizedBox(width: 16.w),
          GestureDetector(
            onTap: onIncrement,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class CoachNutritionEditorMealSection extends StatelessWidget {
  const CoachNutritionEditorMealSection({
    super.key,
    required this.label,
    required this.items,
    required this.onAdd,
  });

  final String label;
  final List<FoodItem> items;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 22.r,
                  height: 22.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppColors.primaryBlue,
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  items.isNotEmpty
                      ? '+ Add Meal (${items.length})'
                      : '+ Add Meal',
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
