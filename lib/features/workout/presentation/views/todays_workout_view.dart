import 'package:athletica/core/widgets/refresh_on_focus.dart';
import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/bilingual_label.dart';
import 'package:athletica/core/utils/rest_time_format.dart';
import 'package:athletica/core/utils/workout_display_format.dart';
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

import 'widgets/today_workout_progress_card.dart';
import 'widgets/today_workout_status_sections.dart';
import 'widgets/workout_status_view.dart';

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
        body: SafeArea(
          child: Builder(
            builder: (context) => RefreshOnFocus(
              onRefresh: () => context.read<WorkoutTodayCubit>().load(),
              child: _Body(userGender: userGender),
            ),
          ),
        ),
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
          buildWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType ||
              (previous is WorkoutTodayLoaded &&
                  current is WorkoutTodayLoaded &&
                  !_sameWorkoutLayout(previous.workout, current.workout)),
          builder: (context, state) => switch (state) {
              WorkoutTodayInitial() ||
              WorkoutTodayLoading() => const TodayWorkoutLoadingView(),
              WorkoutTodayError(:final message) => WorkoutStatusView(
                icon: Icons.error_outline,
                title: 'Could not load today\'s workout',
                message: message,
                actionLabel: 'Retry',
                onAction: () => context.read<WorkoutTodayCubit>().load(),
              ),
              WorkoutTodayLoaded(:final workout) =>
                workout == null
                    ? WorkoutStatusView(
                        icon: Icons.fitness_center,
                        title: 'No workout today',
                        message: 'No workout is assigned for today.',
                        actionLabel: 'Refresh',
                        onAction: () =>
                            context.read<WorkoutTodayCubit>().load(),
                      )
                    : workout.isRest
                    ? TodayWorkoutRestView(workout: workout)
                    : _WorkoutView(
                        workout: workout,
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
    required this.gender,
  });

  final TodayWorkoutEntry workout;
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
          BlocSelector<WorkoutTodayCubit, WorkoutTodayState, int>(
            selector: (state) => state.workout?.exercises
                    .where((exercise) => exercise.completed)
                    .length ??
                completed,
            builder: (context, currentCompleted) => TodayWorkoutProgressCard(
              completed: currentCompleted,
              total: total,
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            'Exercises',
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 10.h),
          if (exercises.isEmpty)
            const TodayWorkoutEmptyExercises()
          else
            ...exercises.asMap().entries.map((entry) {
              final exercise = entry.value;
              return _TodayWorkoutExerciseItem(
                key: ValueKey(
                  exercise.logId.isNotEmpty ? exercise.logId : exercise.id,
                ),
                exercise: exercise,
                order: entry.key + 1,
                gender: gender,
              );
            }),
        ],
      ),
    );
  }
}

class _TodayWorkoutExerciseItem extends StatelessWidget {
  const _TodayWorkoutExerciseItem({
    super.key,
    required this.exercise,
    required this.order,
    required this.gender,
  });

  final TodayExerciseEntry exercise;
  final int order;
  final String? gender;

  @override
  Widget build(BuildContext context) => BlocSelector<
    WorkoutTodayCubit,
    WorkoutTodayState,
    ({bool completed, bool busy})
  >(
    selector: (state) {
      final current = state.workout?.exercises
          .where((candidate) => candidate.logId == exercise.logId)
          .firstOrNull;
      final busy = state is WorkoutTodayLoaded &&
          state.togglingLogId == exercise.logId;
      return (
        completed: current?.completed ?? exercise.completed,
        busy: busy,
      );
    },
    builder: (context, value) => Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: WorkoutExerciseRow(
        order: order,
        name: _exerciseName(exercise),
        primaryMuscle: exercise.exercise?.primaryMuscle.trim() ?? '',
        prescription: formatWorkoutPrescription(exercise.sets, exercise.reps),
        rest: _restLabel(exercise.restTime),
        notes: exercise.notes.trim(),
        thumbnail: ExerciseThumbnail(
          size: 58,
          thumbnailUrl: _thumbnail(exercise, gender),
        ),
        completed: value.completed,
        busy: value.busy,
        onMediaTap: () => _showVideo(context, exercise, gender),
        onCompletionChanged: exercise.logId.isEmpty || value.busy
            ? null
            : (completed) => context.read<WorkoutTodayCubit>().toggle(
                exercise.logId,
                completed,
              ),
      ),
    ),
  );
}

bool _sameWorkoutLayout(TodayWorkoutEntry? previous, TodayWorkoutEntry? next) {
  if (previous == null || next == null) return previous == next;
  if (previous.dayId != next.dayId ||
      previous.title != next.title ||
      previous.dayNumber != next.dayNumber ||
      previous.isRest != next.isRest ||
      previous.note != next.note ||
      previous.exercises.length != next.exercises.length) {
    return false;
  }
  for (var i = 0; i < previous.exercises.length; i++) {
    final a = previous.exercises[i];
    final b = next.exercises[i];
    if (a.logId != b.logId ||
        a.id != b.id ||
        a.exerciseId != b.exerciseId ||
        a.orderNumber != b.orderNumber ||
        a.sets != b.sets ||
        a.reps != b.reps ||
        a.restTime != b.restTime ||
        a.notes != b.notes ||
        a.exercise?.nameEn != b.exercise?.nameEn ||
        a.exercise?.nameAr != b.exercise?.nameAr ||
        a.exercise?.primaryMuscle != b.exercise?.primaryMuscle ||
        a.exercise?.thumbnailUrlMale != b.exercise?.thumbnailUrlMale ||
        a.exercise?.thumbnailUrlFemale != b.exercise?.thumbnailUrlFemale ||
        a.exercise?.videoUrlMale != b.exercise?.videoUrlMale ||
        a.exercise?.videoUrlFemale != b.exercise?.videoUrlFemale) {
      return false;
    }
  }
  return true;
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
