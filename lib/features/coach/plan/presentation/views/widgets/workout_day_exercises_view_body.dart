import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/day_workout.dart';
import 'package:athletica/features/coach/plan/domain/entities/plan_exercise.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/exercise_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutDayExercisesViewBody extends StatefulWidget {
  const WorkoutDayExercisesViewBody({super.key, required this.dayWorkout});

  final DayWorkout dayWorkout;

  @override
  State<WorkoutDayExercisesViewBody> createState() =>
      _WorkoutDayExercisesViewBodyState();
}

class _WorkoutDayExercisesViewBodyState
    extends State<WorkoutDayExercisesViewBody> {
  late DayWorkout _day;

  @override
  void initState() {
    super.initState();
    _day = widget.dayWorkout;
  }

  void _remove(String section, PlanExercise exercise) {
    setState(() {
      switch (section) {
        case 'warmUp':
          _day = _day.copyWith(
            warmUp: _day.warmUp.where((e) => e.id != exercise.id).toList(),
          );
        case 'workout':
          _day = _day.copyWith(
            workout: _day.workout.where((e) => e.id != exercise.id).toList(),
          );
        case 'coolDown':
          _day = _day.copyWith(
            coolDown: _day.coolDown.where((e) => e.id != exercise.id).toList(),
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              _Section(
                title: 'Warm UP',
                exercises: _day.warmUp,
                onDelete: (e) => _remove('warmUp', e),
              ),
              SizedBox(height: 8.h),
              _Section(
                title: 'Workout',
                exercises: _day.workout,
                onDelete: (e) => _remove('workout', e),
              ),
              SizedBox(height: 8.h),
              _Section(
                title: 'Cool Down',
                exercises: _day.coolDown,
                onDelete: (e) => _remove('coolDown', e),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.exercises,
    required this.onDelete,
  });

  final String title;
  final List<PlanExercise> exercises;
  final ValueChanged<PlanExercise> onDelete;

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.semiBold14(context).copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        ...exercises.map((e) => _ExerciseCard(exercise: e, onDelete: onDelete)),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.onDelete});

  final PlanExercise exercise;
  final ValueChanged<PlanExercise> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          const ExerciseThumbnail(size: 64),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              exercise.name,
              style: AppTextStyles.medium13(context).copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20.sp),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.symmetric(horizontal: 8.w),
          ),
          IconButton(
            onPressed: () => onDelete(exercise),
            icon: Icon(Icons.delete_outline, color: Colors.red, size: 20.sp),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
