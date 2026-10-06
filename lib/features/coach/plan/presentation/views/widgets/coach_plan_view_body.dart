import 'coach_plan_type_card.dart';
import 'package:athletica/core/widgets/connection_error_view.dart';
import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/presentation/cubits/coach_plan_overview_cubit.dart';
import 'package:athletica/features/coach/plan/presentation/views/nutrition_plans_list_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/workout_plans_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachPlanViewBody extends StatelessWidget {
  const CoachPlanViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CoachPlanOverviewCubit>()..load(),
      child: BlocBuilder<CoachPlanOverviewCubit, CoachPlanOverviewState>(
        builder: (context, state) {
          final plansCount = switch (state) {
            CoachPlanOverviewLoaded(:final nutritionPlans) =>
              nutritionPlans?.toString() ?? '--',
            _ => '--',
          };
          final workoutCount = switch (state) {
            CoachPlanOverviewLoaded(:final workoutPrograms) =>
              workoutPrograms?.toString() ?? '--',
            _ => '--',
          };
          final activeClientsCount = switch (state) {
            CoachPlanOverviewLoaded(:final activeClients) =>
              activeClients?.toString() ?? '--',
            _ => '--',
          };

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 28.h),
                Text(
                  'My plans',
                  style: AppTextStyles.bold24(
                    context,
                  ).copyWith(color: AppColors.textPrimary, fontSize: 28.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Choose What to manage',
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: 24.h),
                CoachPlanTypeCard(
                  title: 'Workout',
                  subtitle: 'Workouts & programs',
                  stat1Label: 'Programs',
                  stat1Value: workoutCount,
                  stat2Label: 'Active clients',
                  stat2Value: activeClientsCount,
                  iconAsset: 'assets/images/plan/workout_icon.svg',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B4FE8), Color(0xFF2E3A8C)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkoutPlansListView(),
                      ),
                    );
                    // Revalidate the totals after any add/edit on return.
                    if (context.mounted) {
                      context.read<CoachPlanOverviewCubit>().load();
                    }
                  },
                ),
                SizedBox(height: 20.h),
                if (state is CoachPlanOverviewLoaded &&
                    (state.workoutConnectionError ||
                        state.clientsConnectionError))
                  ConnectionErrorView(
                    compact: true,
                    onRetry: () =>
                        context.read<CoachPlanOverviewCubit>().load(),
                  ),
                CoachPlanTypeCard(
                  title: 'Nutrition',
                  subtitle: 'Meal Plan & Diets',
                  stat1Label: 'Plans',
                  stat1Value: plansCount,
                  stat2Label: 'Active clients',
                  stat2Value: activeClientsCount,
                  iconAsset: 'assets/images/plan/nutrition_icon.svg',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB22A4A), Color(0xFF5A0BFC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NutritionPlansListView(),
                      ),
                    );
                    // Revalidate the totals after any add/edit on return.
                    if (context.mounted) {
                      context.read<CoachPlanOverviewCubit>().load();
                    }
                  },
                ),
                if (state is CoachPlanOverviewLoaded &&
                    (state.nutritionConnectionError ||
                        state.clientsConnectionError))
                  ConnectionErrorView(
                    compact: true,
                    onRetry: () =>
                        context.read<CoachPlanOverviewCubit>().load(),
                  ),
                if (state is CoachPlanOverviewError ||
                    (state is CoachPlanOverviewLoaded &&
                        state.error != null)) ...[
                  SizedBox(height: 16.h),
                  Text(
                    state is CoachPlanOverviewError
                        ? state.message
                        : (state as CoachPlanOverviewLoaded).error!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.meduim12(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                  ),
                ],
                SizedBox(height: 32.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
