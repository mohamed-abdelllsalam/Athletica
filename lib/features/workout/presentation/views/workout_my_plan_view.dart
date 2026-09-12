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
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_my_plan_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_my_plan_state.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_today_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_today_state.dart';
import 'package:athletica/features/workout/presentation/views/todays_workout_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutMyPlanRouteArgs {
  const WorkoutMyPlanRouteArgs({this.initialDayNumber, this.userGender});

  final int? initialDayNumber;
  final String? userGender;
}

class WorkoutMyPlanView extends StatelessWidget {
  const WorkoutMyPlanView({super.key, this.initialDayNumber, this.userGender});

  static const String routeName = 'workout-my-plan';
  final int? initialDayNumber;
  final String? userGender;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<WorkoutMyPlanCubit>()..loadActive()),
        BlocProvider(create: (_) => sl<WorkoutTodayCubit>()..load()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        body: SafeArea(
          child: _Body(
            initialDayNumber: initialDayNumber,
            userGender: userGender,
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.initialDayNumber, required this.userGender});

  final int? initialDayNumber;
  final String? userGender;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
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
                'My Plan',
                style: AppTextStyles.bold20(context).copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocConsumer<WorkoutMyPlanCubit, WorkoutMyPlanState>(
            listenWhen: (_, state) =>
                state is WorkoutMyPlanLoaded && state.plan != null,
            listener: (context, state) {
              final loaded = state as WorkoutMyPlanLoaded;
              context.read<WorkoutMyPlanCubit>().loadDetails(loaded.plan!.id);
            },
            builder: (context, state) => switch (state) {
              WorkoutMyPlanInitial() || WorkoutMyPlanLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              WorkoutMyPlanError(:final message) => _StatusView(
                  icon: Icons.error_outline,
                  title: 'Could not load your plan',
                  message: message,
                  actionLabel: 'Retry',
                  onAction: () =>
                      context.read<WorkoutMyPlanCubit>().loadActive(),
                ),
              WorkoutMyPlanLoaded(:final plan) => plan == null
                  ? _StatusView(
                      icon: Icons.fitness_center,
                      title: 'No training plan yet',
                      message: 'Your assigned training plan will appear here.',
                      actionLabel: 'Refresh',
                      onAction: () =>
                          context.read<WorkoutMyPlanCubit>().loadActive(),
                    )
                  : const Center(child: CircularProgressIndicator()),
              WorkoutMyPlanDetailLoaded(:final plan) => _PlanBody(
                  plan: plan,
                  initialDayNumber: initialDayNumber,
                  userGender: userGender,
                ),
            },
          ),
        ),
      ],
    );
  }
}

class _PlanBody extends StatefulWidget {
  const _PlanBody({
    required this.plan,
    required this.initialDayNumber,
    required this.userGender,
  });

  final WorkoutPlanEntry plan;
  final int? initialDayNumber;
  final String? userGender;

  @override
  State<_PlanBody> createState() => _PlanBodyState();
}

class _PlanBodyState extends State<_PlanBody> {
  late int _selectedDayNumber;

  List<PlanDayEntry> get _days => [...widget.plan.days]
    ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));

  @override
  void initState() {
    super.initState();
    final days = _days;
    final requested = widget.initialDayNumber;
    _selectedDayNumber = requested != null &&
            days.any((day) => day.dayNumber == requested)
        ? requested
        : (days.isEmpty ? 0 : days.first.dayNumber);
  }

  @override
  Widget build(BuildContext context) {
    final days = _days;
    if (days.isEmpty) {
      return _StatusView(
        icon: Icons.event_busy_outlined,
        title: 'This plan has no days',
        message: 'Your coach has not added any training days yet.',
        actionLabel: 'Refresh',
        onAction: () => context.read<WorkoutMyPlanCubit>().loadActive(),
      );
    }
    final selected = days.firstWhere(
      (day) => day.dayNumber == _selectedDayNumber,
      orElse: () => days.first,
    );
    final exercises = [...selected.exercises]
      ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

    return RefreshIndicator(
      onRefresh: () => context.read<WorkoutMyPlanCubit>().loadActive(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 28.h),
        children: [
          _PlanHeader(plan: widget.plan, dayCount: days.length),
          SizedBox(height: 16.h),
          SizedBox(
            height: 66.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: days.length,
              separatorBuilder: (_, _) => SizedBox(width: 9.w),
              itemBuilder: (context, index) {
                final day = days[index];
                return _DayChip(
                  key: ValueKey(day.id),
                  day: day,
                  selected: day.dayNumber == selected.dayNumber,
                  onTap: () => setState(
                    () => _selectedDayNumber = day.dayNumber,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            'Day ${selected.dayNumber} — ${selected.isRest ? 'Rest Day' : selected.title}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bold20(context).copyWith(
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          if (selected.note.trim().isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              selected.note.trim(),
              style: AppTextStyles.medium14(context).copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
          SizedBox(height: 14.h),
          if (selected.isRest)
            _RestDay(note: selected.note)
          else if (exercises.isEmpty)
            const _EmptyDay()
          else
            ...exercises.asMap().entries.map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _PlanExerciseRow(
                      key: ValueKey(entry.value.id),
                      exercise: entry.value,
                      order: entry.key + 1,
                      gender: widget.userGender,
                    ),
                  ),
                ),
          if (!selected.isRest && exercises.isNotEmpty) ...[
            BlocBuilder<WorkoutTodayCubit, WorkoutTodayState>(
              builder: (context, state) {
                final today = state is WorkoutTodayLoaded ? state.workout : null;
                if (!_isExecutableToday(selected, today)) {
                  return const SizedBox.shrink();
                }
                final done = today!.exercises.where((e) => e.completed).length;
                final label = today.dayCompleted
                    ? 'View Completed Workout'
                    : done > 0
                        ? 'Continue Workout'
                        : 'Start Workout';
                return Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: SizedBox(
                    height: 52.h,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        TodaysWorkoutView.routeName,
                        arguments: TodaysWorkoutRouteArgs(
                          userGender: widget.userGender,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      icon: Icon(
                        today.dayCompleted
                            ? Icons.check_circle_outline
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        label,
                        style: AppTextStyles.semiBold15(context).copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

bool _isExecutableToday(PlanDayEntry selected, TodayWorkoutEntry? today) {
  if (today == null || today.isRest || today.exercises.isEmpty) return false;
  if (selected.id.isNotEmpty && today.dayId.isNotEmpty) {
    if (selected.id != today.dayId) return false;
  } else if (selected.dayNumber != today.dayNumber) {
    return false;
  }
  return today.exercises.every((exercise) => exercise.logId.isNotEmpty);
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({required this.plan, required this.dayCount});
  final WorkoutPlanEntry plan;
  final int dayCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Training Plan',
            style: AppTextStyles.meduim12(context).copyWith(
              color: AppColors.primaryPurple,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            plan.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bold20(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            '$dayCount ${dayCount == 1 ? 'day' : 'days'} per cycle',
            style: AppTextStyles.medium14(context).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (plan.description.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              plan.description.trim(),
              style: AppTextStyles.medium14(context).copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    super.key,
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final PlanDayEntry day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryPurple : AppColors.cardBackground,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          constraints: BoxConstraints(minWidth: 92.w),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Day ${day.dayNumber}',
                style: AppTextStyles.semiBold14(context).copyWith(
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                day.isRest ? 'Rest' : day.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.meduim12(context).copyWith(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanExerciseRow extends StatelessWidget {
  const _PlanExerciseRow({
    super.key,
    required this.exercise,
    required this.order,
    required this.gender,
  });

  final PlanExerciseEntry exercise;
  final int order;
  final String? gender;

  @override
  Widget build(BuildContext context) {
    final catalog = exercise.exercise;
    final name = buildBilingualLabel(
      primary: catalog?.nameEn ?? exercise.exerciseId,
      arabic: catalog?.nameAr,
      english: catalog?.nameEn,
    );
    final thumbnail = pickGenderedUrl(
      maleUrl: catalog?.thumbnailUrlMale ?? '',
      femaleUrl: catalog?.thumbnailUrlFemale ?? '',
      gender: gender,
    );
    void showVideo() => showExerciseVideoDialog(
          context,
          title: name,
          videoUrl: resolveExerciseVideoUrl(
            maleUrl: catalog?.videoUrlMale ?? '',
            femaleUrl: catalog?.videoUrlFemale ?? '',
            gender: gender,
          ),
          thumbnailUrl: thumbnail,
        );

    return WorkoutExerciseRow(
      order: order,
      name: name,
      primaryMuscle: catalog?.primaryMuscle.trim() ?? '',
      prescription: formatWorkoutPrescription(exercise.sets, exercise.reps),
      rest: exercise.restTime == null
          ? ''
          : 'Rest ${formatRestTime(exercise.restTime)}',
      notes: exercise.notes.trim(),
      thumbnail: ExerciseThumbnail(size: 58, thumbnailUrl: thumbnail),
      onTap: showVideo,
      onMediaTap: showVideo,
    );
  }
}

class _RestDay extends StatelessWidget {
  const _RestDay({required this.note});
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bedtime_outlined,
            color: AppColors.primaryPurple,
            size: 36.sp,
          ),
          SizedBox(height: 10.h),
          Text(
            note.trim().isNotEmpty
                ? note.trim()
                : 'Recover and get ready for your next training day.',
            textAlign: TextAlign.center,
            style: AppTextStyles.medium14(context).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        'No exercises are assigned to this day.',
        textAlign: TextAlign.center,
        style: AppTextStyles.medium14(context).copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({
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
          style: AppTextStyles.bold20(context).copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.medium14(context).copyWith(
            color: AppColors.textSecondary,
          ),
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
