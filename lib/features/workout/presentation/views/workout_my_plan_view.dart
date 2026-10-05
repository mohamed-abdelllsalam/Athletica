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

import 'widgets/workout_my_plan_day_sections.dart';
import 'widgets/workout_my_plan_header.dart';
import 'widgets/workout_status_view.dart';

class WorkoutMyPlanRouteArgs {
  const WorkoutMyPlanRouteArgs({this.initialDayNumber, this.userGender});

  final int? initialDayNumber;
  final String? userGender;
}

class WorkoutMyPlanView extends StatelessWidget {
  const WorkoutMyPlanView({
    super.key,
    this.initialDayNumber,
    this.userGender,
    this.planId,
  });

  static const String routeName = 'workout-my-plan';
  final String? planId;
  final int? initialDayNumber;
  final String? userGender;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = sl<WorkoutMyPlanCubit>();
            if (planId == null) {
              cubit.loadActive();
            } else {
              cubit.loadDetails(planId!);
            }
            return cubit;
          },
        ),
        BlocProvider(create: (_) => sl<WorkoutTodayCubit>()..load()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        body: SafeArea(
          child: _Body(
            planId: planId,
            initialDayNumber: initialDayNumber,
            userGender: userGender,
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.initialDayNumber,
    required this.userGender,
    this.planId,
  });

  final String? planId;
  Future<void> _reload(BuildContext context) => planId == null
      ? context.read<WorkoutMyPlanCubit>().loadActive()
      : context.read<WorkoutMyPlanCubit>().loadDetails(planId!);

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
                style: AppTextStyles.bold20(
                  context,
                ).copyWith(color: AppColors.textPrimary),
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
              WorkoutMyPlanError(:final message) => WorkoutStatusView(
                icon: Icons.error_outline,
                title: 'Could not load your plan',
                message: message,
                actionLabel: 'Retry',
                onAction: () => _reload(context),
              ),
              WorkoutMyPlanLoaded(:final plan) =>
                plan == null
                    ? WorkoutStatusView(
                        icon: Icons.fitness_center,
                        title: 'No training plan yet',
                        message:
                            'Your assigned training plan will appear here.',
                        actionLabel: 'Refresh',
                        onAction: () => _reload(context),
                      )
                    : const Center(child: CircularProgressIndicator()),
              WorkoutMyPlanDetailLoaded(:final plan) => _PlanBody(
                plan: plan,
                onRefresh: () => _reload(context),
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
    required this.onRefresh,
    required this.initialDayNumber,
    required this.userGender,
  });

  final WorkoutPlanEntry plan;
  final Future<void> Function() onRefresh;
  final int? initialDayNumber;
  final String? userGender;

  @override
  State<_PlanBody> createState() => _PlanBodyState();
}

class _PlanBodyState extends State<_PlanBody> {
  late int _selectedDayNumber;

  List<PlanDayEntry> get _days =>
      [...widget.plan.days]..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));

  @override
  void initState() {
    super.initState();
    final days = _days;
    final requested = widget.initialDayNumber;
    _selectedDayNumber =
        requested != null && days.any((day) => day.dayNumber == requested)
        ? requested
        : (days.isEmpty ? 0 : days.first.dayNumber);
  }

  @override
  Widget build(BuildContext context) {
    final days = _days;
    if (days.isEmpty) {
      return WorkoutStatusView(
        icon: Icons.event_busy_outlined,
        title: 'This plan has no days',
        message: 'Your coach has not added any training days yet.',
        actionLabel: 'Refresh',
        onAction: () => widget.onRefresh(),
      );
    }
    final selected = days.firstWhere(
      (day) => day.dayNumber == _selectedDayNumber,
      orElse: () => days.first,
    );
    final exercises = [...selected.exercises]
      ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

    return RefreshIndicator(
      onRefresh: () => widget.onRefresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 28.h),
        children: [
          WorkoutMyPlanHeader(plan: widget.plan, dayCount: days.length),
          SizedBox(height: 16.h),
          WorkoutMyPlanDaySelector(
            days: days,
            selectedDayNumber: selected.dayNumber,
            onSelected: (dayNumber) =>
                setState(() => _selectedDayNumber = dayNumber),
          ),
          SizedBox(height: 18.h),
          Text(
            'Day ${selected.dayNumber} — ${selected.isRest ? 'Rest Day' : selected.title}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bold20(
              context,
            ).copyWith(color: AppColors.textPrimary, height: 1.25),
          ),
          if (selected.note.trim().isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              selected.note.trim(),
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary, height: 1.35),
            ),
          ],
          SizedBox(height: 14.h),
          if (selected.isRest)
            WorkoutMyPlanRestDay(note: selected.note)
          else if (exercises.isEmpty)
            const WorkoutMyPlanEmptyDay()
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
                final today = state is WorkoutTodayLoaded
                    ? state.workout
                    : null;
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
                        style: AppTextStyles.semiBold15(
                          context,
                        ).copyWith(color: Colors.white),
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
