import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/assigned/presentation/views/assigned_view.dart';
import 'package:athletica/features/client_coach/presentation/cubits/client_coach_cubit.dart';
import 'package:athletica/features/client_coach/presentation/cubits/client_coach_state.dart';
import 'package:athletica/features/client_coach/presentation/views/widgets/coach_code_dialog.dart';
import 'package:athletica/features/home/presentation/views/widgets/meal_section.dart';
import 'package:athletica/features/home/presentation/views/widgets/nutrition_summary_card.dart';
import 'package:athletica/features/home/presentation/views/widgets/total_nutritions_bar.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_cubit.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_state.dart';
import 'package:athletica/features/nutrition/presentation/views/my_plan_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionsSection extends StatelessWidget {
  const NutritionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<NutritionTodayCubit>()..load(),
        ),
        BlocProvider(
          create: (_) => sl<ClientCoachCubit>()..loadCoach(),
        ),
      ],
      child: BlocBuilder<ClientCoachCubit, ClientCoachState>(
        builder: (context, coachState) {
          final showNoCoachBanner = coachState is ClientCoachNoCoach;
          final hasCoach = coachState is ClientCoachLoaded;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showNoCoachBanner) ...[
                const _NoCoachBanner(),
                SizedBox(height: 16.h),
              ],
              if (hasCoach)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, AssignedView.routeName),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Assigned Plans',
                              style: AppTextStyles.semiBold14(context)
                                  .copyWith(color: AppColors.primaryBlue),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.primaryBlue,
                              size: 18.sp,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, MyPlanDetailsView.routeName),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'My Plan',
                              style: AppTextStyles.semiBold14(context)
                                  .copyWith(color: AppColors.primaryBlue),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.primaryBlue,
                              size: 18.sp,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              BlocBuilder<NutritionTodayCubit, NutritionTodayState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NutritionSummaryCard(
                        totalCarbs: state.meals.totalCarbs,
                        totalProtein: state.meals.totalProtein,
                        totalFat: state.meals.totalFat,
                        isLoading: state is NutritionTodayLoading,
                      ),
                      SizedBox(height: 24.h),
                      TotalNutritionsBar(meals: state.meals),
                      SizedBox(height: 24.h),
                      MealSection(
                        meals: state.meals.meals,
                        isLoading: state is NutritionTodayLoading,
                        errorMessage:
                            state is NutritionTodayError
                                ? state.message
                                : null,
                        togglingMealLogId: state is NutritionTodayLoaded
                            ? state.togglingMealLogId
                            : null,
                        onRetry: () =>
                            context.read<NutritionTodayCubit>().load(),
                        onToggleComplete: (mealLogId, targetCompleted) =>
                            context
                                .read<NutritionTodayCubit>()
                                .toggleComplete(mealLogId, targetCompleted),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Shown in the nutrition header while the client has no coach. The
/// underlined "Subscribe" opens the coach-code dialog.
class _NoCoachBanner extends StatelessWidget {
  const _NoCoachBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundLight,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: GestureDetector(
          onTap: () async {
            final sent = await showCoachCodeDialog(context);
            if (sent && context.mounted) {
              context.read<ClientCoachCubit>().loadCoach();
            }
          },
          child: Text.rich(
            TextSpan(
              text: "You don't have a nutrition plan yet. ",
              style: AppTextStyles.meduim12(context)
                  .copyWith(color: AppColors.textSecondary),
              children: [
                TextSpan(
                  text: 'Subscribe',
                  style: AppTextStyles.semiBold14(context).copyWith(
                    color: AppColors.primaryBlue,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
