import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_my_plan_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_my_plan_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Client "My Plan" — `GET /workout/my/plans` + details.
/// Null plan shows the empty state.
class WorkoutMyPlanView extends StatelessWidget {
  const WorkoutMyPlanView({super.key});

  static const String routeName = 'workout-my-plan';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkoutMyPlanCubit>()..loadActive(),
      child: const Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        body: SafeArea(child: _Body()),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.textPrimary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'My Workout Plan',
                style: AppTextStyles.bold20(context)
                    .copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<WorkoutMyPlanCubit, WorkoutMyPlanState>(
            builder: (context, state) => switch (state) {
              WorkoutMyPlanInitial() ||
              WorkoutMyPlanLoading() =>
                const Center(child: CircularProgressIndicator()),
              WorkoutMyPlanError(:final message) => Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.medium14(context).copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        TextButton(
                          onPressed: () => context
                              .read<WorkoutMyPlanCubit>()
                              .loadActive(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              WorkoutMyPlanLoaded(:final plan) => plan == null
                  ? _EmptyView(
                      onRefresh: () => context
                          .read<WorkoutMyPlanCubit>()
                          .loadActive(),
                    )
                  : _PlanContent(plan: plan, isArabic: _isArabic(context)),
              WorkoutMyPlanDetailLoaded(:final plan) =>
                _PlanContent(plan: plan, isArabic: _isArabic(context)),
            },
          ),
        ),
      ],
    );
  }
}

class _PlanContent extends StatelessWidget {
  const _PlanContent({required this.plan, required this.isArabic});

  final WorkoutPlanEntry plan;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final days = [...plan.days]
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    return RefreshIndicator(
      onRefresh: () => context.read<WorkoutMyPlanCubit>().loadActive(),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          Text(
            plan.title,
            style: AppTextStyles.semiBold15(context)
                .copyWith(color: AppColors.textPrimary),
          ),
          if (plan.description.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              plan.description,
              style: AppTextStyles.meduim12(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: 4.h),
          Text(
            'Started ${plan.startDate} • ${plan.dayCount} days',
            style: AppTextStyles.meduim12(context).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          ...days.map(
            (day) => Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day ${day.dayNumber} — ${day.title}',
                    style: AppTextStyles.semiBold14(context).copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (day.isRest)
                    Text(
                      'Rest day',
                      style: AppTextStyles.medium14(context).copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  else if (day.exercises.isEmpty)
                    Text(
                      'No exercises.',
                      style: AppTextStyles.medium14(context).copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  else
                    ...([...day.exercises]
                      ..sort((a, b) =>
                          a.orderNumber.compareTo(b.orderNumber))).map(
                      (ex) => Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${ex.orderNumber}. ${ex.exercise?.localizedName(isArabic) ?? ex.exerciseId}',
                                style: AppTextStyles.medium14(context)
                                    .copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '${ex.sets ?? '—'}×${ex.reps ?? '—'}',
                              style: AppTextStyles.meduim12(context)
                                  .copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center,
                color: AppColors.textSecondary, size: 40.sp),
            SizedBox(height: 12.h),
            Text(
              'No workout plan assigned yet.',
              style: AppTextStyles.medium14(context)
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            TextButton(onPressed: onRefresh, child: const Text('Refresh')),
          ],
        ),
      ),
    );
  }
}
