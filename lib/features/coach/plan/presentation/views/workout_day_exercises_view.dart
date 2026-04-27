import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/workout_day_exercises_view_body.dart';
import 'package:flutter/material.dart';

class WorkoutDayExercisesView extends StatelessWidget {
  const WorkoutDayExercisesView({super.key, required this.day});

  final ProgramDay day;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(child: WorkoutDayExercisesViewBody(day: day)),
    );
  }
}
