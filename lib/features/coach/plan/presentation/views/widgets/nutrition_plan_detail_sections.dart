import 'nutrition_plan_daily_targets.dart';
import 'nutrition_plan_meal_card.dart';
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
        CoachNutritionPlanDailyTargets(
          plan: plan,
          isCreateMode: isCreateMode,
          caloriesController: caloriesController,
          proteinController: proteinController,
          fatController: fatController,
          carbsController: carbsController,
          onMacrosChanged: onMacrosChanged,
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
                          child: CoachNutritionPlanMealCard(
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
