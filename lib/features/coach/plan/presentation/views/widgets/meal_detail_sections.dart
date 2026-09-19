import 'meal_ingredient_card.dart';
import 'meal_nutrition_summary.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MealDetailsTab extends StatelessWidget {
  const MealDetailsTab({
    super.key,
    required this.searchController,
    required this.mealNoteController,
    required this.ingredients,
    required this.query,
    required this.onQueryChanged,
    required this.onRemove,
    required this.onEditGrams,
    required this.onAddIngredients,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalFat,
    required this.totalCarbs,
    required this.onSave,
  });

  final TextEditingController searchController;
  final TextEditingController mealNoteController;
  final List<Ingredient> ingredients;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<Ingredient> onRemove;
  final ValueChanged<Ingredient> onEditGrams;
  final VoidCallback onAddIngredients;
  final int totalCalories;
  final int totalProtein;
  final int totalFat;
  final int totalCarbs;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      children: [
        Text(
          'Ingredients',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44.h,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: onQueryChanged,
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
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: IconButton(
                onPressed: onAddIngredients,
                icon: Icon(
                  Icons.add,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (ingredients.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Center(
              child: Text(
                'No ingredients added',
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...ingredients.map(
            (ingredient) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: CoachMealIngredientCard(
                ingredient: ingredient,
                onRemove: () => onRemove(ingredient),
                onEditGrams: () => onEditGrams(ingredient),
              ),
            ),
          ),
        SizedBox(height: 8.h),
        CoachMealNutritionSummary(
          totalCalories: totalCalories,
          totalProtein: totalProtein,
          totalFat: totalFat,
          totalCarbs: totalCarbs,
        ),
        SizedBox(height: 16.h),
        Text(
          'Meal Notes (Optional)',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 100.h,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextField(
            controller: mealNoteController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Add notes about this meal ..',
              hintStyle: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14.r),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Save Changes',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
