import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/meal_type_labels.dart';
import 'package:athletica/core/utils/nutrition_display_format.dart';
import 'package:athletica/core/widgets/nutrition/nutrition_card.dart';
import 'package:athletica/core/widgets/nutrition/nutrition_food_list.dart';
import 'package:athletica/core/widgets/nutrition/nutrition_macros.dart';
import 'package:athletica/core/widgets/nutrition/nutrition_status.dart';
import 'package:athletica/features/nutrition/domain/entities/my_plan.dart';
import 'package:athletica/features/nutrition/presentation/cubits/my_plan_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;

class MyPlanDetailsView extends StatelessWidget {
  const MyPlanDetailsView({super.key});
  static const String routeName = 'client-my-plan';
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<MyPlanDetailsCubit>()..load(),
    child: Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          children: [
            const NutritionAppBar(title: 'My Plan'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                child: BlocBuilder<MyPlanDetailsCubit, MyPlanDetailsState>(
                  builder: (context, state) => switch (state) {
                    MyPlanDetailsInitial() || MyPlanDetailsLoading() =>
                      const NutritionLoading(plan: true),
                    MyPlanDetailsNoPlan() => NutritionNoPlan(
                      onRefresh: () =>
                          context.read<MyPlanDetailsCubit>().load(),
                    ),
                    MyPlanDetailsError(:final message) => NutritionStatus(
                      message: message,
                      action: 'Retry',
                      onAction: () => context.read<MyPlanDetailsCubit>().load(),
                    ),
                    MyPlanDetailsLoaded(:final plan) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PlanOverview(plan: plan),
                        SizedBox(height: 16.h),
                        if (plan.meals.isEmpty)
                          const NutritionStatus(
                            message: 'This plan has no meals yet.',
                          )
                        else
                          _PlanMeals(
                            key: ValueKey(plan),
                            meals: plan.sortedMeals,
                          ),
                      ],
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PlanOverview extends StatelessWidget {
  const _PlanOverview({required this.plan});
  final MyPlan plan;
  @override
  Widget build(BuildContext context) => NutritionCard(
    outlined: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Nutrition Plan',
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.primaryPurple),
        ),
        SizedBox(height: 6.h),
        Text(
          plan.title,
          textDirection: intl.Bidi.detectRtlDirectionality(plan.title)
              ? TextDirection.rtl
              : TextDirection.ltr,
          style: AppTextStyles.bold24(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        if (plan.description.trim().isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            plan.description.trim(),
            textDirection: intl.Bidi.detectRtlDirectionality(plan.description)
                ? TextDirection.rtl
                : TextDirection.ltr,
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary, height: 1.4),
          ),
        ],
        SizedBox(height: 16.h),
        Wrap(
          spacing: 16.w,
          runSpacing: 8.h,
          children: [
            Text(
              '${plan.mealCount} ${plan.mealCount == 1 ? 'meal' : 'meals'}',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
            if (plan.hasCompleteMealData)
              Text(
                '${formatNutrition(plan.totalCalories)} kcal',
                style: AppTextStyles.semiBold15(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
          ],
        ),
        if (plan.hasCompleteMealData) ...[
          SizedBox(height: 16.h),
          NutritionMacros(
            protein: plan.totalProtein,
            carbs: plan.totalCarbs,
            fat: plan.totalFat,
          ),
        ],
      ],
    ),
  );
}

/// Selection is local UI state; the API data stays in MyPlanDetailsCubit.
class _PlanMeals extends StatefulWidget {
  const _PlanMeals({super.key, required this.meals});
  final List<MyPlanMeal> meals;
  @override
  State<_PlanMeals> createState() => _PlanMealsState();
}

class _PlanMealsState extends State<_PlanMeals> {
  int _selected = 0;
  @override
  Widget build(BuildContext context) {
    final meal = widget.meals[_selected];
    final type = labelForMealType(meal.mealType);
    final title = meal.notes.trim().isEmpty ? type : meal.notes.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < widget.meals.length; i++)
                Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: Semantics(
                    selected: _selected == i,
                    child: Material(
                      color: _selected == i
                          ? AppColors.primaryBlue
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12.r),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => setState(() => _selected = i),
                        child: Container(
                          width: 124.w,
                          constraints: BoxConstraints(
                            minHeight: 56.h.clamp(48, double.infinity),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                          child: Column(
                            children: [
                              Text(
                                widget.meals[i].notes.trim().isEmpty
                                    ? labelForMealType(widget.meals[i].mealType)
                                    : widget.meals[i].notes.trim(),
                                textAlign: TextAlign.center,
                                style: AppTextStyles.semiBold14(
                                  context,
                                ).copyWith(color: AppColors.textPrimary),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                'Meal ${widget.meals[i].mealOrder}',
                                style: AppTextStyles.medium13(
                                  context,
                                ).copyWith(color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 18.h),
        Text(
          title,
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        if (meal.notes.trim().isNotEmpty)
          Text(
            type,
            style: AppTextStyles.medium13(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
        SizedBox(height: 4.h),
        Text(
          '${meal.foods.length} foods · ${formatNutrition(meal.totalCalories)} kcal',
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 8.h),
        NutritionMacros(
          protein: meal.totalProtein,
          carbs: meal.totalCarbs,
          fat: meal.totalFat,
          compact: true,
        ),
        SizedBox(height: 12.h),
        NutritionFoodList(foods: meal.foods),
      ],
    );
  }
}
