import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/bilingual_label.dart';
import 'package:athletica/core/utils/rest_time_format.dart';
import 'package:athletica/core/utils/workout_display_format.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:athletica/core/widgets/exercise_video.dart';
import 'package:athletica/core/widgets/workout_exercise_row.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/exercise_thumbnail.dart';
import 'package:athletica/features/workout/domain/entities/today_workout.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_today_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_today_state.dart';
import 'package:athletica/features/workout/presentation/views/workout_complete_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TodaysWorkoutRouteArgs {
  const TodaysWorkoutRouteArgs({this.userGender});
  final String? userGender;
}

/// The backend-backed executable workout for the client's current day.
class TodaysWorkoutView extends StatelessWidget {
  const TodaysWorkoutView({super.key, this.userGender});

  static const String routeName = 'todays-workout';
  final String? userGender;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkoutTodayCubit>()..load(),
      child: Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        body: SafeArea(child: _Body(userGender: userGender)),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({required this.userGender});
  final String? userGender;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  bool _celebrationStarted = false;

  void _showCompletion() {
    if (_celebrationStarted || !mounted) return;
    _celebrationStarted = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => const WorkoutCompleteView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _AppBar(),
        Expanded(
          child: BlocConsumer<WorkoutTodayCubit, WorkoutTodayState>(
            listenWhen: (previous, current) {
              if (current is! WorkoutTodayLoaded) return false;
              final freshError =
                  current.errorMessage != null &&
                  (previous is! WorkoutTodayLoaded ||
                      previous.errorMessage != current.errorMessage);
              return current.dayCompletionConfirmed || freshError;
            },
            listener: (context, state) {
              final loaded = state as WorkoutTodayLoaded;
              if (loaded.errorMessage != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(loaded.errorMessage!)));
              } else if (loaded.dayCompletionConfirmed) {
                _showCompletion();
              }
            },
            builder: (context, state) => switch (state) {
              WorkoutTodayInitial() ||
              WorkoutTodayLoading() => const _LoadingView(),
              WorkoutTodayError(:final message) => _MessageView(
                icon: Icons.error_outline,
                title: 'Could not load today\'s workout',
                message: message,
                actionLabel: 'Retry',
                onAction: () => context.read<WorkoutTodayCubit>().load(),
              ),
              WorkoutTodayLoaded(:final workout, :final togglingLogId) =>
                workout == null
                    ? _MessageView(
                        icon: Icons.fitness_center,
                        title: 'No workout today',
                        message: 'No workout is assigned for today.',
                        actionLabel: 'Refresh',
                        onAction: () =>
                            context.read<WorkoutTodayCubit>().load(),
                      )
                    : workout.isRest
                    ? _RestView(workout: workout)
                    : _WorkoutView(
                        workout: workout,
                        togglingLogId: togglingLogId,
                        gender: widget.userGender,
                      ),
            },
          ),
        ),
      ],
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 16.w, 10.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
          Text(
            "Today's Workout",
            style: AppTextStyles.bold20(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _WorkoutView extends StatelessWidget {
  const _WorkoutView({
    required this.workout,
    required this.togglingLogId,
    required this.gender,
  });

  final TodayWorkoutEntry workout;
  final String? togglingLogId;
  final String? gender;

  @override
  Widget build(BuildContext context) {
    final exercises = [...workout.exercises]
      ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
    final completed = exercises.where((exercise) => exercise.completed).length;
    final total = exercises.length;
    return RefreshIndicator(
      onRefresh: () => context.read<WorkoutTodayCubit>().load(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
        children: [
          Text(
            'Day ${workout.dayNumber} — ${workout.title}',
            style: AppTextStyles.bold24(
              context,
            ).copyWith(color: AppColors.textPrimary, height: 1.2),
          ),
          if (workout.note.trim().isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              workout.note.trim(),
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary, height: 1.35),
            ),
          ],
          SizedBox(height: 18.h),
          _ProgressCard(completed: completed, total: total),
          SizedBox(height: 18.h),
          Text(
            'Exercises',
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 10.h),
          if (exercises.isEmpty)
            const _InlineEmpty()
          else
            ...exercises.asMap().entries.map((entry) {
              final exercise = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: WorkoutExerciseRow(
                  key: ValueKey(
                    exercise.logId.isNotEmpty ? exercise.logId : exercise.id,
                  ),
                  order: entry.key + 1,
                  name: _exerciseName(exercise),
                  primaryMuscle: exercise.exercise?.primaryMuscle.trim() ?? '',
                  prescription: formatWorkoutPrescription(
                    exercise.sets,
                    exercise.reps,
                  ),
                  rest: _restLabel(exercise.restTime),
                  notes: exercise.notes.trim(),
                  thumbnail: ExerciseThumbnail(
                    size: 58,
                    thumbnailUrl: _thumbnail(exercise, gender),
                  ),
                  completed: exercise.completed,
                  busy: togglingLogId == exercise.logId,
                  onMediaTap: () => _showVideo(context, exercise, gender),
                  onCompletionChanged: exercise.logId.isEmpty
                      ? null
                      : (value) => context.read<WorkoutTodayCubit>().toggle(
                          exercise.logId,
                          value,
                        ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.completed, required this.total});
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Workout Progress',
                  style: AppTextStyles.semiBold14(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
              ),
              Text(
                '$completed / $total',
                style: AppTextStyles.semiBold14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
              backgroundColor: AppColors.surfaceDark,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestView extends StatelessWidget {
  const _RestView({required this.workout});
  final TodayWorkoutEntry workout;

  @override
  Widget build(BuildContext context) {
    return _MessageView(
      icon: Icons.bedtime_outlined,
      title: 'Day ${workout.dayNumber} — Rest Day',
      message: workout.note.trim().isNotEmpty
          ? workout.note.trim()
          : 'Recover today and come back ready for your next session.',
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(
        'No exercises are assigned to this day.',
        textAlign: TextAlign.center,
        style: AppTextStyles.medium14(
          context,
        ).copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 64.h),
      children: [
        Icon(icon, color: AppColors.primaryPurple, size: 42.sp),
        SizedBox(height: 14.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 8.h),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        if (actionLabel != null && onAction != null) ...[
          SizedBox(height: 16.h),
          Center(
            child: TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ),
        ],
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          SkeletonBox(width: 220.w, height: 28.h, radius: 8.r),
          SizedBox(height: 18.h),
          SkeletonBox(height: 86.h, radius: 16.r),
          SizedBox(height: 18.h),
          for (var index = 0; index < 4; index++) ...[
            SkeletonBox(height: 92.h, radius: 14.r),
            SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}

String _exerciseName(TodayExerciseEntry exercise) => buildBilingualLabel(
  primary: exercise.exercise?.nameEn ?? exercise.exerciseId,
  arabic: exercise.exercise?.nameAr,
  english: exercise.exercise?.nameEn,
);

String _restLabel(int? seconds) =>
    seconds == null ? '' : 'Rest ${formatRestTime(seconds)}';

String _thumbnail(TodayExerciseEntry exercise, String? gender) =>
    pickGenderedUrl(
      maleUrl: exercise.exercise?.thumbnailUrlMale ?? '',
      femaleUrl: exercise.exercise?.thumbnailUrlFemale ?? '',
      gender: gender,
    );

void _showVideo(
  BuildContext context,
  TodayExerciseEntry exercise,
  String? gender,
) {
  showExerciseVideoDialog(
    context,
    title: _exerciseName(exercise),
    videoUrl: resolveExerciseVideoUrl(
      maleUrl: exercise.exercise?.videoUrlMale ?? '',
      femaleUrl: exercise.exercise?.videoUrlFemale ?? '',
      gender: gender,
    ),
    thumbnailUrl: _thumbnail(exercise, gender),
  );
}
