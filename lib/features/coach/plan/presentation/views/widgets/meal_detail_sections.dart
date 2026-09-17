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
              child: _IngredientCard(
                ingredient: ingredient,
                onRemove: () => onRemove(ingredient),
                onEditGrams: () => onEditGrams(ingredient),
              ),
            ),
          ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nutrition Summary',
                style: AppTextStyles.semiBold14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MacroStat(
                    value: '$totalCalories',
                    label: 'Calories',
                    color: AppColors.primaryBlue,
                  ),
                  _MacroStat(
                    value: '${totalProtein}g',
                    label: 'Protein',
                    color: const Color(0xFF4CAF50),
                  ),
                  _MacroStat(
                    value: '${totalFat}g',
                    label: 'Fat',
                    color: const Color(0xFFFFB300),
                  ),
                  _MacroStat(
                    value: '${totalCarbs}g',
                    label: 'Carbs',
                    color: const Color(0xFF42A5F5),
                  ),
                ],
              ),
            ],
          ),
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

class _IngredientCard extends StatelessWidget {
  const _IngredientCard({
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

class _MacroStat extends StatelessWidget {
  const _MacroStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bold24(
            context,
          ).copyWith(color: color, fontSize: 18.sp),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: AppTextStyles.meduim12(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Grams Edit Sheet ──────────────────────────────────────────────────────────

class MealNoteTab extends StatelessWidget {
  const MealNoteTab({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Write Note',
            style: AppTextStyles.semiBold14(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Type Your Note !',
                  hintStyle: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Submit',
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
