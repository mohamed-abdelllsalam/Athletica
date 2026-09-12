import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/workout_day_exercises_view_body.dart';
import 'package:flutter/material.dart';

/// Result of editing a day: updated exercises + name + note, or [deleted]
/// when the day was removed. Popped as `null` when the edit was cancelled.
typedef WorkoutDayEditResult = ({
  List<ProgramExercise> exercises,
  String name,
  String note,
  bool deleted,
});

class WorkoutDayExercisesView extends StatelessWidget {
  const WorkoutDayExercisesView({
    super.key,
    required this.day,
    this.isCreateMode = false,
  });

  final ProgramDay day;

  /// When true the day name is editable inline and a delete-day action is
  /// shown in the header (create mode). Saved templates keep the
  /// read-only title with no delete action.
  final bool isCreateMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: WorkoutDayExercisesViewBody(
          day: day,
          isCreateMode: isCreateMode,
        ),
      ),
    );
  }
}
