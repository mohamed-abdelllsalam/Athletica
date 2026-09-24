import 'package:athletica/core/widgets/refresh_on_focus.dart';
import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_state.dart';
import 'package:athletica/features/workout/domain/entities/today_workout.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_today_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_today_state.dart';
import 'package:athletica/features/workout/presentation/views/todays_workout_view.dart';
import 'package:athletica/features/workout/presentation/views/workout_my_plan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Completed/total exercise counts from real backend state — never faked.
({int done, int total}) todayProgress(TodayWorkoutEntry workout) {
  final total = workout.exercises.length;
  final done = workout.exercises.where((e) => e.completed).length;
  return (done: done, total: total);
}

/// Profile gender for gender-matched demo media ([HomeView] provides
/// [ProfileCubit] above this subtree); null falls back to male.
String? _profileGender(BuildContext context) =>
    switch (context.read<ProfileCubit>().state) {
      ProfileLoaded(:final profile) => profile.gender,
      ProfileUpdating(:final profile) => profile.gender,
      ProfileImageUploading(:final profile) => profile.gender,
      ProfileImageUploaded(:final profile) => profile.gender,
      ProfileImageDeleted(:final profile) => profile.gender,
      ProfileError(:final profile) => profile?.gender,
      _ => null,
    };

void _openMyPlan(BuildContext context, {int? dayNumber}) {
  Navigator.pushNamed(
    context,
    WorkoutMyPlanView.routeName,
    arguments: WorkoutMyPlanRouteArgs(
      initialDayNumber: dayNumber,
      userGender: _profileGender(context),
    ),
  ).then((_) {
    if (context.mounted) context.read<WorkoutTodayCubit>().load();
  });
}

void _openToday(BuildContext context, {required String? gender}) {
  Navigator.pushNamed(
    context,
    TodaysWorkoutView.routeName,
    arguments: TodaysWorkoutRouteArgs(userGender: gender),
  ).then((_) {
    if (context.mounted) context.read<WorkoutTodayCubit>().load();
  });
}

/// Client daily workout — compact "Today's Workout" overview card.
/// Full execution lives in [TodaysWorkoutView], full program browsing in
/// [WorkoutMyPlanView]; `{workout: null}` shows the empty state.
class WorkoutsSection extends StatelessWidget {
  const WorkoutsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkoutTodayCubit>()..load(),
      child: Builder(
        builder: (context) => RefreshOnFocus(
          onRefresh: () => context.read<WorkoutTodayCubit>().load(),
          child: const _WorkoutsBody(),
        ),
      ),
    );
  }
}

class _WorkoutsBody extends StatelessWidget {
  const _WorkoutsBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          //   decoration: BoxDecoration(
          //     color: AppColors.primaryPurple.withValues(alpha: 0.1),
          //     borderRadius: BorderRadius.circular(12.r),
          //     border: Border.all(
          //       color: AppColors.primaryPurple.withValues(alpha: 0.2),
          //     ),
          //   ),
          //   child: Text(
          //     'Show up even on the days you don\u2019t feel like it — that\u2019s where transformation begins.',
          //     maxLines: 2,
          //     overflow: TextOverflow.ellipsis,
          //     style: AppTextStyles.meduim12(
          //       context,
          //     ).copyWith(color: AppColors.textSecondary, height: 1.35),
          //   ),
          // ),
          SizedBox(height: 16.h),
          BlocConsumer<WorkoutTodayCubit, WorkoutTodayState>(
            listenWhen: (prev, next) {
              if (next is! WorkoutTodayLoaded) return false;
              final freshError =
                  next.errorMessage != null &&
                  (prev is! WorkoutTodayLoaded ||
                      prev.errorMessage != next.errorMessage);
              return freshError;
            },
            listener: (context, state) {
              final loaded = state as WorkoutTodayLoaded;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(loaded.errorMessage!)));
            },
            builder: (context, state) => switch (state) {
              WorkoutTodayInitial() ||
              WorkoutTodayLoading() => const _TodayCardShimmer(),
              WorkoutTodayError(:final message) => _CardError(
                message: message,
                onRetry: () => context.read<WorkoutTodayCubit>().load(),
              ),
              WorkoutTodayLoaded(:final workout) =>
                workout == null
                    ? _EmptyCard(
                        onRefresh: () =>
                            context.read<WorkoutTodayCubit>().load(),
                      )
                    : workout.isRest
                    ? _RestCard(note: workout.note)
                    : _TodayWorkoutCard(workout: workout),
            },
          ),
        ],
      ),
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard({required this.workout});

  final TodayWorkoutEntry workout;

  @override
  Widget build(BuildContext context) {
    final progress = todayProgress(workout);
    final done = progress.done;
    final total = progress.total;
    final completed = workout.dayCompleted;
    final label = completed
        ? 'Completed'
        : (done > 0 ? 'Continue Workout' : 'Start Workout');
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Today's Workout",
                  style: AppTextStyles.semiBold15(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
              ),
              GestureDetector(
                onTap: () => _openMyPlan(context, dayNumber: workout.dayNumber),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Plan',
                      style: AppTextStyles.semiBold14(
                        context,
                      ).copyWith(color: AppColors.primaryBlue),
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
          SizedBox(height: 8.h),
          Text(
            'Day ${workout.dayNumber} — ${workout.title}',
            style: AppTextStyles.semiBold14(
              context,
            ).copyWith(color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            total == 0
                ? 'No exercises assigned'
                : '$done of $total exercises completed',
            style: AppTextStyles.meduim12(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
          if (total > 0) ...[
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: done / total,
                minHeight: 6.h,
                backgroundColor: AppColors.surfaceDark,
                valueColor: AlwaysStoppedAnimation<Color>(
                  completed ? AppColors.streakGreen : AppColors.primaryBlue,
                ),
              ),
            ),
          ],
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () =>
                  _openToday(context, gender: _profileGender(context)),
              style: ElevatedButton.styleFrom(
                backgroundColor: completed
                    ? AppColors.surfaceDark
                    : AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (completed)
                    Padding(
                      padding: EdgeInsets.only(right: 6.w),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.streakGreen,
                        size: 18.sp,
                      ),
                    ),
                  Text(
                    label,
                    style: AppTextStyles.semiBold14(context).copyWith(
                      color: completed ? AppColors.streakGreen : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestCard extends StatelessWidget {
  const _RestCard({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            "Today's Workout",
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 8.h),
          Icon(Icons.bedtime, color: AppColors.textSecondary, size: 28.sp),
          SizedBox(height: 6.h),
          Text(
            'Rest Day',
            style: AppTextStyles.semiBold14(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 4.h),
          Text(
            note.isNotEmpty ? note : 'Recover for your next session.',
            style: AppTextStyles.meduim12(
              context,
            ).copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            "Today's Workout",
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 8.h),
          Text(
            'No workout assigned for today.',
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          TextButton(onPressed: onRefresh, child: const Text('Refresh')),
        ],
      ),
    );
  }
}

class _CardError extends StatelessWidget {
  const _CardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            message,
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _TodayCardShimmer extends StatelessWidget {
  const _TodayCardShimmer();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 140.w, height: 16.h, radius: 6.r),
            SizedBox(height: 10.h),
            const SkeletonBox(height: 12, radius: 6),
            SizedBox(height: 12.h),
            SkeletonBox(height: 48.h, radius: 12.r),
          ],
        ),
      ),
    );
  }
}
