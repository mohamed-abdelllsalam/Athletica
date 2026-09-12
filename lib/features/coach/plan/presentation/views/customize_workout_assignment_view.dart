import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/plan/presentation/cubits/customize_workout_assignment_cubit.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/customize_workout_assignment_view_body.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "Customize Workout Assignment" — reached from the template detail
/// assign sheet after picking a client. The coach tunes per-exercise loads
/// for THIS client; confirming assigns a snapshot plan and applies the
/// loads on it. The template itself is never modified.
class CustomizeWorkoutAssignmentView extends StatelessWidget {
  const CustomizeWorkoutAssignmentView({
    super.key,
    required this.template,
    required this.coachClientId,
    required this.clientName,
  });

  final WorkoutTemplateEntry template;
  final String coachClientId;
  final String clientName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: BlocProvider(
          create: (_) => sl<CustomizeWorkoutAssignmentCubit>(),
          child: CustomizeWorkoutAssignmentViewBody(
            template: template,
            coachClientId: coachClientId,
            clientName: clientName,
          ),
        ),
      ),
    );
  }
}
