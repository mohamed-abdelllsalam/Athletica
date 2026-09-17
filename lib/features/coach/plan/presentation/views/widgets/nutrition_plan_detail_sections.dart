import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionPlanOverviewTab extends StatelessWidget {
  const NutritionPlanOverviewTab({
    super.key,
    required this.plan,
    required this.meals,
    required this.isCreateMode,
    required this.descriptionController,
    required this.descriptionHasError,
    required this.caloriesController,
    required this.proteinController,
    required this.fatController,
    required this.carbsController,
    required this.onMacrosChanged,
    required this.onAddMeal,
    required this.onReorder,
    required this.onMealTap,
  });

  final NutritionPlan plan;
  final List<Meal> meals;
  final bool isCreateMode;
  final TextEditingController descriptionController;
  final bool descriptionHasError;
  final TextEditingController caloriesController;
  final TextEditingController proteinController;
  final TextEditingController fatController;
  final TextEditingController carbsController;
  final VoidCallback onMacrosChanged;
  final VoidCallback onAddMeal;

  /// Drag & drop reorder: local list in create mode, backend
  /// `PUT .../meals/reorder` for persisted templates.
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<Meal> onMealTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      children: [
        Text(
          'Program Overview',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary, fontSize: 16.sp),
        ),
        SizedBox(height: 8.h),
        if (isCreateMode)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(10.r),
                  border: descriptionHasError
                      ? Border.all(color: Colors.redAccent)
                      : null,
                ),
                child: TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  minLines: 1,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                  decoration: InputDecoration(
                    hintText: 'Add a program description…',
                    hintStyle: AppTextStyles.medium14(context).copyWith(
                      color: descriptionHasError
                          ? Colors.redAccent
                          : AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (descriptionHasError) ...[
                SizedBox(height: 6.h),
                Text(
                  'Description is required',
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: Colors.redAccent),
                ),
              ],
            ],
          )
        else
          Text(
            plan.description,
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
        SizedBox(height: 16.h),
        // Daily targets card
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
                'Daily targets',
                style: AppTextStyles.semiBold14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (isCreateMode) ...[
                    _MacroInput(
                      controller: caloriesController,
                      label: 'Calories',
                      color: AppColors.primaryBlue,
                      onChanged: (_) => onMacrosChanged(),
                    ),
                    _MacroInput(
                      controller: proteinController,
                      label: 'Protein',
                      color: const Color(0xFF4CAF50),
                      onChanged: (_) => onMacrosChanged(),
                      suffix: 'g',
                    ),
                    _MacroInput(
                      controller: fatController,
                      label: 'Fat',
                      color: const Color(0xFFFFB300),
                      onChanged: (_) => onMacrosChanged(),
                      suffix: 'g',
                    ),
                    _MacroInput(
                      controller: carbsController,
                      label: 'Carbs',
                      color: const Color(0xFF42A5F5),
                      onChanged: (_) => onMacrosChanged(),
                      suffix: 'g',
                    ),
                  ] else ...[
                    _MacroStat(
                      value: '${plan.calories}',
                      label: 'Calories',
                      color: AppColors.primaryBlue,
                    ),
                    _MacroStat(
                      value: '${plan.proteinGrams}g',
                      label: 'Protein',
                      color: const Color(0xFF4CAF50),
                    ),
                    _MacroStat(
                      value: '${plan.fatGrams}g',
                      label: 'Fat',
                      color: const Color(0xFFFFB300),
                    ),
                    _MacroStat(
                      value: '${plan.carbsGrams}g',
                      label: 'Carbs',
                      color: const Color(0xFF42A5F5),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Meal Plan',
              style: AppTextStyles.semiBold14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            GestureDetector(
              onTap: onAddMeal,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryBlue),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: AppColors.primaryBlue, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Add Meal',
                      style: AppTextStyles.meduim12(
                        context,
                      ).copyWith(color: AppColors.primaryBlue),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        if (meals.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Center(
              child: Text(
                'No meals yet',
                style: AppTextStyles.meduim12(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            buildDefaultDragHandles: false,
            onReorder: onReorder,
            proxyDecorator: (child, index, animation) => AnimatedBuilder(
              animation: animation,
              builder: (_, child) => Material(
                color: Colors.transparent,
                elevation: 6 * animation.value,
                shadowColor: Colors.black54,
                borderRadius: BorderRadius.circular(14.r),
                child: child,
              ),
              child: child,
            ),
            children: [
              for (var i = 0; i < meals.length; i++)
                Container(
                  key: ValueKey(meals[i].id),
                  margin: EdgeInsets.only(bottom: 12.h),
                  // Long-press anywhere on the card also starts a drag;
                  // the ≡ handle starts one immediately.
                  child: ReorderableDelayedDragStartListener(
                    index: i,
                    child: Row(
                      children: [
                        ReorderableDragStartListener(
                          index: i,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Icon(
                              Icons.drag_handle,
                              color: AppColors.textSecondary,
                              size: 22.sp,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _MealCard(
                            meal: meals[i],
                            onTap: () => onMealTap(meals[i]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ],
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

class _MacroInput extends StatelessWidget {
  const _MacroInput({
    required this.controller,
    required this.label,
    required this.color,
    required this.onChanged,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final Color color;
  final ValueChanged<String> onChanged;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 56.w,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: onChanged,
            style: AppTextStyles.bold24(
              context,
            ).copyWith(color: color, fontSize: 18.sp),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: AppTextStyles.bold24(
                context,
              ).copyWith(color: color.withValues(alpha: 0.4), fontSize: 18.sp),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          suffix == null ? label : '$label ($suffix)',
          style: AppTextStyles.meduim12(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.onTap});

  final Meal meal;
  final VoidCallback onTap;

  static IconData _iconForType(String type) => switch (type) {
    'Breakfast' => Icons.wb_sunny_outlined,
    'Lunch' => Icons.restaurant_outlined,
    'Snack' => Icons.cake_outlined,
    'Dinner' => Icons.nightlight_outlined,
    _ => Icons.local_cafe_outlined,
  };

  static Color _bgColorForType(String type) => switch (type) {
    'Breakfast' => const Color(0xFF2C6E3A),
    'Lunch' => const Color(0xFF1C5C2A),
    'Snack' => const Color(0xFF3D2A7A),
    'Dinner' => const Color(0xFF2A1C5A),
    _ => const Color(0xFF1C2A5A),
  };

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
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: _bgColorForType(meal.type),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                _iconForType(meal.type),
                color: Colors.white,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: AppTextStyles.semiBold14(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${meal.calories} CAL . ${meal.proteinGrams}G Protein',
                    style: AppTextStyles.meduim12(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Note Tab ─────────────────────────────────────────────────────────────────
