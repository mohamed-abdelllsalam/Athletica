import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/home/presentation/views/widgets/meal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MealSection extends StatelessWidget {
  const MealSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Carbohydrate: 2600',
            style: AppTextStyles.medium16(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                'Day 1',
                style: AppTextStyles.semiBold15(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textPrimary,
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _buildMealGroup(
            context,
            title: 'Breakfast',
            meals: [
              const MealCard(
                emoji: '🥣',
                name: 'oats&banana',
                calories: 478,
                carbs: 89,
                protein: 18,
                fat: 7.2,
              ),
            ],
          ),

          SizedBox(height: 16.h),

          _buildMealGroup(
            context,
            title: 'Lunch',
            meals: [
              const MealCard(
                emoji: '🥩',
                name: 'Steak &potatoes',
                calories: 700,
                carbs: 109,
                protein: 31,
                fat: 9.1,
              ),
            ],
          ),

          SizedBox(height: 16.h),

          _buildMealGroup(
            context,
            title: 'Snacks',
            meals: [
              const MealCard(
                emoji: '🥜',
                name: 'Nuts',
                calories: 607,
                carbs: 109,
                protein: 29,
                fat: 16,
              ),
            ],
          ),

          SizedBox(height: 16.h),

          _buildMealGroup(
            context,
            title: 'Dinner',
            meals: [
              const MealCard(
                emoji: '🍳',
                name: 'Eggs',
                calories: 308,
                carbs: 60,
                protein: 24,
                fat: 9,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealGroup(
    BuildContext context, {
    required String title,
    required List<MealCard> meals,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackgroundLight,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            title,
            style: AppTextStyles.semiBold14(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ),
        SizedBox(height: 10.h),
        ...meals,
      ],
    );
  }
}
