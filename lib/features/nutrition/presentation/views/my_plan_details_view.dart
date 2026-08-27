import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/meal_type_labels.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:athletica/core/widgets/bilingual_text.dart';
import 'package:athletica/features/nutrition/domain/entities/meal_food.dart';
import 'package:athletica/features/nutrition/domain/entities/my_plan.dart';
import 'package:athletica/features/nutrition/presentation/cubits/my_plan_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Client-side plan details: shows the active plan's meals and foods.
class MyPlanDetailsView extends StatelessWidget {
  const MyPlanDetailsView({super.key});

  static const String routeName = 'client-my-plan';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MyPlanDetailsCubit>()..load(),
      child: const _MyPlanDetailsBody(),
    );
  }
}

class _MyPlanDetailsBody extends StatelessWidget {
  const _MyPlanDetailsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: BlocBuilder<MyPlanDetailsCubit, MyPlanDetailsState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 24.sp,
              ),
            ),
          ),
          Text(
            'My Plan',
            style: AppTextStyles.semiBold15(context)
                .copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, MyPlanDetailsState state) {
    return switch (state) {
      MyPlanDetailsInitial() || MyPlanDetailsLoading() => AppShimmer(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 90.h, radius: 16.r),
                SizedBox(height: 20.h),
                for (var i = 0; i < 3; i++) ...[
                  SkeletonBox(height: 40.h, radius: 12.r),
                  SizedBox(height: 10.h),
                  SkeletonBox(height: 120.h, radius: 14.r),
                  SizedBox(height: 16.h),
                ],
              ],
            ),
          ),
        ),
      MyPlanDetailsNoPlan() => Center(
          child: Text(
            "You don't have an active plan yet.",
            style: AppTextStyles.medium14(context)
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
      MyPlanDetailsError(:final message) => Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    color: AppColors.textSecondary, size: 48.sp),
                SizedBox(height: 12.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.medium14(context)
                      .copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: 16.h),
                TextButton(
                  onPressed: () => context.read<MyPlanDetailsCubit>().load(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      MyPlanDetailsLoaded(:final plan) =>
        _PlanContent(plan: plan),
    };
  }
}

class _PlanContent extends StatelessWidget {
  const _PlanContent({required this.plan});

  final MyPlan plan;

  List<MyPlanMeal> get _sortedMeals {
    final meals = [...plan.meals];
    meals.sort((a, b) {
      final rankA = mealTypeOrder[a.mealType] ?? '9';
      final rankB = mealTypeOrder[b.mealType] ?? '9';
      if (rankA != rankB) return rankA.compareTo(rankB);
      return a.mealOrder.compareTo(b.mealOrder);
    });
    return meals;
  }

  @override
  Widget build(BuildContext context) {
    final meals = _sortedMeals;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16.r),
            ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: AppTextStyles.bold20(context)
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  if (plan.description.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      plan.description,
                      style: AppTextStyles.medium13(context)
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _MacroChip(label: 'kcal', value: plan.totalCalories),
                    SizedBox(width: 8.w),
                    _MacroChip(label: 'P', value: plan.totalProtein),
                    SizedBox(width: 8.w),
                    _MacroChip(label: 'C', value: plan.totalCarbs),
                    SizedBox(width: 8.w),
                    _MacroChip(label: 'F', value: plan.totalFat),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          if (meals.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 32.h),
                child: Text(
                  'This plan has no meals yet.',
                  style: AppTextStyles.medium14(context)
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...meals.map((meal) => _MealCard(meal: meal)),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({required this.label, required this.value});

  final String label;
  final num value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        '$label ${_format(value)}',
        style: AppTextStyles.meduim11(context)
            .copyWith(color: AppColors.primaryBlue),
      ),
    );
  }

  String _format(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});

  final MyPlanMeal meal;

  @override
  Widget build(BuildContext context) {
    final label = labelForMealType(meal.mealType);

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundLight,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    meal.notes.isNotEmpty ? meal.notes : label,
                    style: AppTextStyles.semiBold15(context)
                        .copyWith(color: AppColors.textPrimary),
                  ),
                ),
                Text(
                  '${meal.totalCalories.toStringAsFixed(0)} kcal',
                  style: AppTextStyles.meduim12(context)
                      .copyWith(color: AppColors.primaryBlue),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppTextStyles.meduim11(context)
                  .copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 10.h),
            if (meal.foods.isEmpty)
              Text(
                'No foods in this meal.',
                style: AppTextStyles.meduim12(context)
                    .copyWith(color: AppColors.textSecondary),
              )
            else
              ...meal.foods.map((food) => _FoodRow(food: food)),
          ],
        ),
      ),
    );
  }
}

class _FoodRow extends StatelessWidget {
  const _FoodRow({required this.food});

  final MealFood food;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (food.nameEn != null &&
                    food.nameAr != null &&
                    food.nameEn != food.nameAr)
                  BilingualText(
                    english: food.nameEn!,
                    arabic: food.nameAr!,
                    style: AppTextStyles.medium14(context)
                        .copyWith(color: AppColors.textPrimary),
                  )
                else
                  Text(
                    food.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.medium14(context)
                        .copyWith(color: AppColors.textPrimary),
                  ),
                Text(
                  '${_formatNum(food.quantity)} ${food.servingUnit} · '
                  'P ${_formatNum(food.protein)} · C ${_formatNum(food.carbs)}'
                  ' · F ${_formatNum(food.fat)}',
                  style: AppTextStyles.meduim11(context)
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '${food.calories.toStringAsFixed(0)} kcal',
            style: AppTextStyles.medium13(context)
                .copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  String _formatNum(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}
