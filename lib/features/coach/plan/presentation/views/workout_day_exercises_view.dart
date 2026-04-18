import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/plan/domain/entities/day_workout.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/workout_day_exercises_view_body.dart';
import 'package:flutter/material.dart';

class WorkoutDayExercisesView extends StatelessWidget {
  const WorkoutDayExercisesView({super.key, required this.dayWorkout});

  final DayWorkout dayWorkout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(child: WorkoutDayExercisesViewBody(dayWorkout: dayWorkout)),
    );
  }
}
