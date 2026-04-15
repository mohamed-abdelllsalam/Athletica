import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/home/presentation/views/widgets/workout_data.dart';
import 'package:athletica/features/workout_session/presentation/cubits/workout_session_cubit.dart';
import 'package:athletica/features/workout_session/presentation/cubits/workout_session_state.dart';
import 'package:athletica/features/workout_session/presentation/views/widgets/rest_timer_bottom_sheet.dart';
import 'package:athletica/features/workout_session/presentation/views/widgets/set_row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutSessionViewBody extends StatelessWidget {
  const WorkoutSessionViewBody({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
  });

  final WorkoutExercise exercise;
  final int exerciseIndex;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkoutSessionCubit>();

    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(exercise: exercise),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    _DateRow(),
                    SizedBox(height: 8.h),
                    _NotesRow(),
                    SizedBox(height: 16.h),
                    Divider(
                        color: AppColors.textTertiary.withValues(alpha: 0.4),
                        thickness: 0.5),
                    SizedBox(height: 12.h),
                    _ExerciseHeader(
                        exercise: exercise, exerciseIndex: exerciseIndex),
                    SizedBox(height: 12.h),
                    _SetTableHeader(),
                    SizedBox(height: 4.h),
                    BlocBuilder<WorkoutSessionCubit, WorkoutSessionState>(
                      buildWhen: (prev, curr) => prev.sets != curr.sets,
                      builder: (context, state) {
                        return Column(
                          children: state.sets.asMap().entries.map((e) {
                            return SetRowWidget(
                              key: ValueKey(e.key),
                              entry: e.value,
                              onKgChanged: (kg) => cubit.updateKg(e.key, kg),
                              onRepsChanged: (r) =>
                                  cubit.updateReps(e.key, r),
                              onToggleComplete: () =>
                                  cubit.toggleComplete(e.key),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    Divider(
                        color: AppColors.textTertiary.withValues(alpha: 0.4),
                        thickness: 0.5),
                    SizedBox(height: 20.h),
                    Center(child: _RestTimerButton()),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.exercise});
  final WorkoutExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          BlocSelector<WorkoutSessionCubit, WorkoutSessionState, Duration>(
            selector: (s) => s.elapsed,
            builder: (_, elapsed) => _ElapsedTimer(elapsed: elapsed),
          ),
          const Spacer(),
          _ActionButton(
            label: 'Discard',
            filled: false,
            onTap: () => Navigator.pop(context),
          ),
          SizedBox(width: 8.w),
          _ActionButton(
            label: 'Save',
            filled: true,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _ElapsedTimer extends StatelessWidget {
  const _ElapsedTimer({required this.elapsed});
  final Duration elapsed;

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        _format(elapsed),
        style: AppTextStyles.semiBold14(context)
            .copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: filled ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.semiBold14(context)
              .copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ── Date & notes ──────────────────────────────────────────────────────────────

class _DateRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final label =
        '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';

    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.medium14(context)
              .copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(width: 6.w),
        Icon(Icons.edit_outlined,
            color: AppColors.textSecondary, size: 16.sp),
      ],
    );
  }
}

class _NotesRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.edit_outlined, color: AppColors.primaryBlue, size: 16.sp),
        SizedBox(width: 6.w),
        Text(
          'Add notes here',
          style: AppTextStyles.medium14(context)
              .copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

// ── Exercise header ───────────────────────────────────────────────────────────

class _ExerciseHeader extends StatelessWidget {
  const _ExerciseHeader(
      {required this.exercise, required this.exerciseIndex});
  final WorkoutExercise exercise;
  final int exerciseIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$exerciseIndex  ',
          style: AppTextStyles.medium14(context)
              .copyWith(color: AppColors.textSecondary),
        ),
        Text(
          exercise.name,
          style: AppTextStyles.semiBold14(context)
              .copyWith(color: AppColors.primaryBlue),
        ),
        SizedBox(width: 4.w),
        Icon(Icons.chevron_right,
            color: AppColors.primaryBlue, size: 18.sp),
      ],
    );
  }
}

// ── Set table header ──────────────────────────────────────────────────────────

class _SetTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.medium13(context)
        .copyWith(color: AppColors.textSecondary);
    return Row(
      children: [
        SizedBox(width: 28.w + 12.w),
        Expanded(flex: 3, child: Text('Previous', style: style)),
        Expanded(
            flex: 2,
            child: Text('Target', style: style, textAlign: TextAlign.center)),
        SizedBox(
            width: 44.w,
            child: Text('KG', style: style, textAlign: TextAlign.center)),
        SizedBox(width: 6.w),
        SizedBox(
            width: 44.w,
            child: Text('Reps', style: style, textAlign: TextAlign.center)),
        SizedBox(width: 8.w + 28.w),
      ],
    );
  }
}

// ── Rest timer button ─────────────────────────────────────────────────────────

class _RestTimerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showRestTimerSheet(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryBlue, width: 1.5),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined,
                color: AppColors.primaryBlue, size: 18.sp),
            SizedBox(width: 6.w),
            Text(
              'Rest Timer',
              style: AppTextStyles.semiBold14(context)
                  .copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
