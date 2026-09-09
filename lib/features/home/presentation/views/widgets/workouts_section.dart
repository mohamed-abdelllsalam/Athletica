import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:athletica/features/home/presentation/views/widgets/workout_card.dart';
import 'package:athletica/features/workout/domain/entities/today_workout.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_today_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_today_state.dart';
import 'package:athletica/features/workout/presentation/views/workout_history_view.dart';
import 'package:athletica/features/workout/presentation/views/workout_my_plan_view.dart';
import 'package:athletica/features/workout_session/presentation/views/workout_session_view.dart';
import 'package:athletica/features/home/presentation/views/widgets/workout_data.dart'
    show WorkoutExercise;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Client daily workout — `GET /workout/today` + per-exercise
/// complete/uncomplete via `log_id`. Reuses [WorkoutCard] visuals;
/// `{workout: null}` shows the empty state.
class WorkoutsSection extends StatelessWidget {
  const WorkoutsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkoutTodayCubit>()..load(),
      child: const _WorkoutsBody(),
    );
  }
}

class _WorkoutsBody extends StatelessWidget {
  const _WorkoutsBody();

  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"Show up even on the days\nyou don\'t feel like it — that\'s\nwhere the real transformation\nbegins. I\'m not just training\nyour body, I\'m building your\ndiscipline',
            style: AppTextStyles.bold20(
              context,
            ).copyWith(color: AppColors.primaryBlue, height: 1.3),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _HeaderLink(
                label: 'My Plan',
                onTap: () => Navigator.pushNamed(
                    context, WorkoutMyPlanView.routeName),
              ),
              SizedBox(width: 16.w),
              _HeaderLink(
                label: 'History',
                onTap: () => Navigator.pushNamed(
                    context, WorkoutHistoryView.routeName),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          BlocConsumer<WorkoutTodayCubit, WorkoutTodayState>(
            listenWhen: (prev, next) {
              if (next is! WorkoutTodayLoaded) return false;
              final wasDone = prev is WorkoutTodayLoaded &&
                  (prev.workout?.dayCompleted ?? false);
              final justCompleted =
                  !wasDone && (next.workout?.dayCompleted ?? false);
              final freshError = next.errorMessage != null &&
                  (prev is! WorkoutTodayLoaded ||
                      prev.errorMessage != next.errorMessage);
              return justCompleted || freshError;
            },
            listener: (context, state) {
              final loaded = state as WorkoutTodayLoaded;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    loaded.errorMessage ??
                        'Workout day completed — nice work!',
                  ),
                ),
              );
            },
            builder: (context, state) => switch (state) {
              WorkoutTodayInitial() ||
              WorkoutTodayLoading() =>
                const _WorkoutsShimmer(),
              WorkoutTodayError(:final message) => _ErrorView(
                  message: message,
                  onRetry: () => context.read<WorkoutTodayCubit>().load(),
                ),
              WorkoutTodayLoaded(:final workout, :final togglingLogId) =>
                _LoadedView(
                  workout: workout,
                  togglingLogId: togglingLogId,
                  isArabic: _isArabic(context),
                  onRefresh: () => context.read<WorkoutTodayCubit>().load(),
                  onToggle: (logId, target) =>
                      context.read<WorkoutTodayCubit>().toggle(logId, target),
                ),
            },
          ),
        ],
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({
    required this.workout,
    required this.togglingLogId,
    required this.isArabic,
    required this.onRefresh,
    required this.onToggle,
  });

  final TodayWorkoutEntry? workout;
  final String? togglingLogId;
  final bool isArabic;
  final VoidCallback onRefresh;
  final void Function(String logId, bool targetCompleted) onToggle;

  @override
  Widget build(BuildContext context) {
    final w = workout;
    if (w == null) {
      return _EmptyView(onRefresh: onRefresh);
    }
    if (w.isRest) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DayHeader(title: w.title, dayNumber: w.dayNumber, isRest: true),
          SizedBox(height: 16.h),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text(
                'Rest day — recover and come back stronger.',
                style: AppTextStyles.medium14(context)
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }
    if (w.exercises.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DayHeader(title: w.title, dayNumber: w.dayNumber, isRest: false),
          SizedBox(height: 16.h),
          _EmptyView(onRefresh: onRefresh),
        ],
      );
    }
    // Backend is the source of truth for day cycling — render the
    // returned day_number/title directly, never compute locally.
    final sorted = [...w.exercises]
      ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DayHeader(
          title: w.title,
          dayNumber: w.dayNumber,
          isRest: false,
          dayCompleted: w.dayCompleted,
        ),
        SizedBox(height: 16.h),
        ...sorted.asMap().entries.map(
              (entry) => _CompletableCard(
                exercise: entry.value,
                index: entry.key,
                isArabic: isArabic,
                busy: togglingLogId == entry.value.logId,
                onToggle: onToggle,
              ),
            ),
      ],
    );
  }
}

/// Same [WorkoutCard] visuals, with a completion checkbox bound to
/// `log_id` (never `exercise_id`). The Reps button still opens the
/// existing session view for local set tracking.
class _CompletableCard extends StatelessWidget {
  const _CompletableCard({
    required this.exercise,
    required this.index,
    required this.isArabic,
    required this.busy,
    required this.onToggle,
  });

  final TodayExerciseEntry exercise;
  final int index;
  final bool isArabic;
  final bool busy;
  final void Function(String logId, bool targetCompleted) onToggle;

  @override
  Widget build(BuildContext context) {
    final name = exercise.displayName(isArabic);
    final sets = exercise.sets ?? 0;
    final reps = exercise.reps?.toString() ?? '—';
    final notes = exercise.notes.trim();
    final muscle = exercise.exercise?.primaryMuscle.trim() ?? '';
    final bottom = notes.isNotEmpty
        ? notes
        : (muscle.isNotEmpty ? muscle : 'Tap Reps to start this exercise');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 14.h),
          child: busy
              ? SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Checkbox(
                  value: exercise.completed,
                  activeColor: AppColors.streakGreen,
                  onChanged: (_) =>
                      onToggle(exercise.logId, !exercise.completed),
                ),
        ),
        Expanded(
          child: Opacity(
            opacity: exercise.completed ? 0.65 : 1,
            child: WorkoutCard(
              name: name,
              sets: sets,
              repsRange: reps,
              restRange: muscle.isEmpty ? '—' : muscle,
              bottomText: bottom,
              onRepsTap: () => Navigator.pushNamed(
                context,
                WorkoutSessionView.routeName,
                arguments: (
                  exercise: WorkoutExercise(
                    name: name,
                    sets: sets == 0 ? 1 : sets,
                    repsRange: reps,
                    restRange: muscle.isEmpty ? '—' : muscle,
                    bottomText: bottom,
                  ),
                  exerciseIndex: index + 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderLink extends StatelessWidget {
  const _HeaderLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
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
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.title,
    required this.dayNumber,
    required this.isRest,
    this.dayCompleted = false,
  });

  final String title;
  final int dayNumber;
  final bool isRest;
  final bool dayCompleted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Type Of Training: ',
          style: AppTextStyles.medium16(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            isRest ? 'Rest Day' : 'Day $dayNumber — $title',
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (dayCompleted && !isRest)
          Icon(Icons.check_circle, color: AppColors.streakGreen, size: 20.sp),
      ],
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
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No workout assigned for today.',
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: AppTextStyles.medium14(context)
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _WorkoutsShimmer extends StatelessWidget {
  const _WorkoutsShimmer();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    SkeletonBox(width: 90.w, height: 60.h, radius: 8.r),
                    SizedBox(width: 12.w),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(height: 12, radius: 6),
                          SizedBox(height: 8),
                          SkeletonBox(width: 140, height: 10, radius: 5),
                        ],
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
