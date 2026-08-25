import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/meal_type_labels.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:athletica/features/home/presentation/views/widgets/meal_card.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MealSection extends StatelessWidget {
  const MealSection({
    super.key,
    required this.meals,
    required this.isLoading,
    this.errorMessage,
    this.togglingMealLogId,
    this.onRetry,
    required this.onToggleComplete,
  });

  final List<TodayMeal> meals;
  final bool isLoading;
  final String? errorMessage;
  final String? togglingMealLogId;
  final VoidCallback? onRetry;
  final void Function(String mealLogId, bool targetCompleted)
      onToggleComplete;

  /// Groups meals by type in a stable breakfast→lunch→snacks→dinner order,
  /// keeping any unknown meal types at the end.
  List<MapEntry<String, List<TodayMeal>>> get _grouped {
    final groups = <String, List<TodayMeal>>{};
    for (final meal in meals) {
      groups.putIfAbsent(meal.mealType, () => []).add(meal);
    }
    final entries = groups.entries.toList()
      ..sort((a, b) {
        final rankA = mealTypeOrder[a.key] ?? '9';
        final rankB = mealTypeOrder[b.key] ?? '9';
        return rankA.compareTo(rankB);
      });
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading && meals.isEmpty)
            AppShimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < 2; i++) ...[
                    SkeletonBox(
                      width: 110.w,
                      height: 30.h,
                      radius: 8.r,
                    ),
                    SizedBox(height: 10.h),
                    for (var j = 0; j < 2; j++)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            children: [
                              SkeletonBox(width: 32.r, height: 32.r, radius: 10.r),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SkeletonBox(height: 12.h, radius: 6.r),
                                    SizedBox(height: 8.h),
                                    SkeletonBox(
                                        width: 140.w, height: 10.h, radius: 5.r),
                                    SizedBox(height: 6.h),
                                    SkeletonBox(
                                        width: 100.w, height: 10.h, radius: 5.r),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          if (!isLoading && errorMessage != null && meals.isEmpty)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.medium14(context)
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (!isLoading && meals.isEmpty)
            Center(
              child: Text(
                'No nutrition plan for today.',
                style: AppTextStyles.medium14(context)
                    .copyWith(color: AppColors.textSecondary),
              ),
            )
          else
            ..._buildGroups(context),
        ],
      ),
    );
  }

  List<Widget> _buildGroups(BuildContext context) {
    final widgets = <Widget>[];
    for (final group in _grouped) {
      final label = labelForMealType(group.key);
      widgets
        ..add(SizedBox(height: widgets.isEmpty ? 0 : 16.h))
        ..add(_buildGroupHeader(context, label));
      for (final meal in group.value) {
        widgets.add(MealCard(
          key: ValueKey(meal.mealLogId),
          mealType: meal.mealType,
          name: meal.notes.isNotEmpty ? meal.notes : label,
          calories: meal.totalCalories.toDouble(),
          carbs: meal.totalCarbs.toDouble(),
          protein: meal.totalProtein.toDouble(),
          fat: meal.totalFat.toDouble(),
          completed: meal.completed,
          busy: togglingMealLogId == meal.mealLogId,
          onToggle: meal.foods.isEmpty
              ? null
              : () => onToggleComplete(meal.mealLogId, !meal.completed),
        ));
      }
    }
    return widgets;
  }

  Widget _buildGroupHeader(BuildContext context, String title) {
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
            style: AppTextStyles.semiBold14(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
