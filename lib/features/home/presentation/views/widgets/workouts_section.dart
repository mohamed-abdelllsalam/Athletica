import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/bilingual_label.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:athletica/core/widgets/exercise_video.dart';
import 'package:athletica/features/home/presentation/views/widgets/workout_card.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_state.dart';
import 'package:athletica/features/workout/domain/entities/today_workout.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_my_plan_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_my_plan_state.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_today_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_today_state.dart';
import 'package:athletica/features/workout_session/presentation/views/workout_session_view.dart';
import 'package:athletica/features/home/presentation/views/widgets/workout_data.dart'
    show WorkoutExercise;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

/// Opens the gender-matched demo video for a client exercise.
void _playDemo(BuildContext context, TodayExerciseEntry entry) {
  final catalog = entry.exercise;
  final gender = _profileGender(context);
  final maleUrl = catalog?.videoUrlMale ?? '';
  final femaleUrl = catalog?.videoUrlFemale ?? '';
  showExerciseVideoDialog(
    context,
    title: buildBilingualLabel(
      primary: catalog?.nameEn ?? entry.exerciseId,
      arabic: catalog?.nameAr,
      english: catalog?.nameEn,
    ),
    thumbnailUrl: pickGenderedUrl(
      maleUrl: catalog?.thumbnailUrlMale ?? '',
      femaleUrl: catalog?.thumbnailUrlFemale ?? '',
      gender: gender,
    ),
    videoUrl: resolveExerciseVideoUrl(
      maleUrl: maleUrl,
      femaleUrl: femaleUrl,
      gender: gender,
    ),
  );
}

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
          BlocConsumer<WorkoutTodayCubit, WorkoutTodayState>(
            listenWhen: (prev, next) {
              if (next is! WorkoutTodayLoaded) return false;
              final wasDone =
                  prev is WorkoutTodayLoaded &&
                  (prev.workout?.dayCompleted ?? false);
              final justCompleted =
                  !wasDone && (next.workout?.dayCompleted ?? false);
              final freshError =
                  next.errorMessage != null &&
                  (prev is! WorkoutTodayLoaded ||
                      prev.errorMessage != next.errorMessage);
              return justCompleted || freshError;
            },
            listener: (context, state) {
              final loaded = state as WorkoutTodayLoaded;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    loaded.errorMessage ?? 'Workout day completed — nice work!',
                  ),
                ),
              );
            },
            builder: (context, state) => switch (state) {
              WorkoutTodayInitial() ||
              WorkoutTodayLoading() => const _WorkoutsShimmer(),
              WorkoutTodayError(:final message) => _ErrorView(
                message: message,
                onRetry: () => context.read<WorkoutTodayCubit>().load(),
              ),
              WorkoutTodayLoaded(:final workout, :final togglingLogId) =>
                BlocProvider(
                  create: (_) => sl<WorkoutMyPlanCubit>()..loadActive(),
                  child: _PlanDayPicker(
                    workout: workout,
                    togglingLogId: togglingLogId,
                    onRefresh: () => context.read<WorkoutTodayCubit>().load(),
                    onToggle: (logId, target) =>
                        context.read<WorkoutTodayCubit>().toggle(logId, target),
                  ),
                ),
            },
          ),
        ],
      ),
    );
  }
}

/// Day list in place of the single "Day N — title" header: the client picks
/// a day chip and sees that day's exercises (bilingual). The current day
/// keeps its completable cards; other days are read-only. Without plan
/// data it falls back to the legacy single-day view.
class _PlanDayPicker extends StatefulWidget {
  const _PlanDayPicker({
    required this.workout,
    required this.togglingLogId,
    required this.onRefresh,
    required this.onToggle,
  });

  final TodayWorkoutEntry? workout;
  final String? togglingLogId;
  final VoidCallback onRefresh;
  final void Function(String logId, bool targetCompleted) onToggle;

  @override
  State<_PlanDayPicker> createState() => _PlanDayPickerState();
}

class _PlanDayPickerState extends State<_PlanDayPicker> {
  int? _selectedDayNumber;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutMyPlanCubit, WorkoutMyPlanState>(
      listener: (context, state) {
        if (state is WorkoutMyPlanLoaded && state.plan != null) {
          context.read<WorkoutMyPlanCubit>().loadDetails(state.plan!.id);
        }
      },
      builder: (context, state) {
        final days = state is WorkoutMyPlanDetailLoaded
            ? ([...state.plan.days]
                ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber)))
            : const <PlanDayEntry>[];
        if (days.isEmpty) {
          // No plan data — legacy single-day view.
          return _LoadedView(
            workout: widget.workout,
            togglingLogId: widget.togglingLogId,
            onRefresh: widget.onRefresh,
            onToggle: widget.onToggle,
          );
        }
        final todayNumber = widget.workout?.dayNumber;
        final selected =
            _selectedDayNumber ??
            (todayNumber != null && days.any((d) => d.dayNumber == todayNumber)
                ? todayNumber
                : days.first.dayNumber);
        final selectedDay = days.firstWhere(
          (d) => d.dayNumber == selected,
          orElse: () => days.first,
        );
        final showingToday =
            widget.workout != null && selectedDay.dayNumber == todayNumber;
        final todayNote = showingToday ? (widget.workout?.note ?? '') : '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type Of Training: ',
              style: AppTextStyles.medium16(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 40.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: days.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final day = days[index];
                  final isSelected = day.dayNumber == selectedDay.dayNumber;
                  final isToday = day.dayNumber == todayNumber;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedDayNumber = day.dayNumber),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.buttonColor
                            : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20.r),
                        border: day.isRest && !isSelected
                            ? Border.all(
                                color: AppColors.textTertiary.withValues(
                                  alpha: 0.4,
                                ),
                              )
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Day ${day.dayNumber}',
                            style: AppTextStyles.semiBold14(context).copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (isToday) ...[
                            SizedBox(width: 4.w),
                            Container(
                              width: 6.r,
                              height: 6.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.streakGreen,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              selectedDay.title,
              style: AppTextStyles.semiBold15(
                context,
              ).copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
            if (todayNote.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                todayNote,
                style: AppTextStyles.meduim12(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
            ],
            SizedBox(height: 16.h),
            if (showingToday)
              _TodayDayBody(
                workout: widget.workout,
                togglingLogId: widget.togglingLogId,
                onRefresh: widget.onRefresh,
                onToggle: widget.onToggle,
              )
            else
              _ReadOnlyDayBody(day: selectedDay, onRefresh: widget.onRefresh),
          ],
        );
      },
    );
  }
}

/// Today's content without the day header (the chips replace it).
class _TodayDayBody extends StatelessWidget {
  const _TodayDayBody({
    required this.workout,
    required this.togglingLogId,
    required this.onRefresh,
    required this.onToggle,
  });

  final TodayWorkoutEntry? workout;
  final String? togglingLogId;
  final VoidCallback onRefresh;
  final void Function(String logId, bool targetCompleted) onToggle;

  @override
  Widget build(BuildContext context) {
    final w = workout;
    if (w == null) {
      return _EmptyView(onRefresh: onRefresh);
    }
    if (w.isRest) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Text(
            'Rest day — recover and come back stronger.',
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (w.exercises.isEmpty) {
      return _EmptyView(onRefresh: onRefresh);
    }
    final sorted = [...w.exercises]
      ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (w.dayCompleted)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.streakGreen,
                  size: 20.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Completed',
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: AppColors.streakGreen),
                ),
              ],
            ),
          ),
        ...sorted.asMap().entries.map(
          (entry) => _CompletableCard(
            exercise: entry.value,
            index: entry.key,
            busy: togglingLogId == entry.value.logId,
            onToggle: onToggle,
          ),
        ),
      ],
    );
  }
}

/// Any non-today plan day: bilingual exercises, read-only.
class _ReadOnlyDayBody extends StatelessWidget {
  const _ReadOnlyDayBody({required this.day, required this.onRefresh});

  final PlanDayEntry day;
  final VoidCallback onRefresh;

  String _exerciseName(PlanExerciseEntry ex) => buildBilingualLabel(
    primary: ex.exercise?.nameEn ?? ex.exerciseId,
    arabic: ex.exercise?.nameAr,
    english: ex.exercise?.nameEn,
  );

  @override
  Widget build(BuildContext context) {
    if (day.isRest) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Text(
            'Rest day — recover for the next session.',
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final exercises = [...day.exercises]
      ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
    if (exercises.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Text(
            'No exercises.',
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: exercises
            .map(
              (ex) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${ex.orderNumber}. ${_exerciseName(ex)}',
                        style: AppTextStyles.medium14(
                          context,
                        ).copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      '${ex.sets ?? '—'}×${ex.reps ?? '—'}',
                      style: AppTextStyles.meduim12(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({
    required this.workout,
    required this.togglingLogId,
    required this.onRefresh,
    required this.onToggle,
  });

  final TodayWorkoutEntry? workout;
  final String? togglingLogId;
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
          _DayHeader(
            title: w.title,
            dayNumber: w.dayNumber,
            isRest: true,
            note: w.note,
          ),
          SizedBox(height: 16.h),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text(
                'Rest day — recover and come back stronger.',
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textSecondary),
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
          note: w.note,
        ),
        SizedBox(height: 16.h),
        ...sorted.asMap().entries.map(
          (entry) => _CompletableCard(
            exercise: entry.value,
            index: entry.key,
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
    required this.busy,
    required this.onToggle,
  });

  final TodayExerciseEntry exercise;
  final int index;
  final bool busy;
  final void Function(String logId, bool targetCompleted) onToggle;

  @override
  Widget build(BuildContext context) {
    final catalog = exercise.exercise;
    final name = buildBilingualLabel(
      primary: catalog?.nameEn ?? exercise.exerciseId,
      arabic: catalog?.nameAr,
      english: catalog?.nameEn,
    );
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
              onPlayTap: () => _playDemo(context, exercise),
              thumbnailUrl: pickGenderedUrl(
                maleUrl: catalog?.thumbnailUrlMale ?? '',
                femaleUrl: catalog?.thumbnailUrlFemale ?? '',
                gender: _profileGender(context),
              ),
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

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.title,
    required this.dayNumber,
    required this.isRest,
    this.dayCompleted = false,
    this.note = '',
  });

  final String title;
  final int dayNumber;
  final bool isRest;
  final bool dayCompleted;

  /// Coach tip (DOC_6 §1.4); hidden when empty.
  final String note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        ),
        if (note.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            note,
            style: AppTextStyles.meduim12(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
        ],
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
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
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
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
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
