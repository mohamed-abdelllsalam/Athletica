import 'package:athletica/features/home/presentation/views/widgets/workout_data.dart';
import 'package:athletica/features/workout_session/presentation/cubits/workout_session_cubit.dart';
import 'package:athletica/features/workout_session/presentation/views/widgets/workout_session_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutSessionView extends StatelessWidget {
  const WorkoutSessionView({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
  });

  static const String routeName = 'workoutSessionView';

  final WorkoutExercise exercise;
  final int exerciseIndex;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkoutSessionCubit(exercise),
      child: WorkoutSessionViewBody(
        exercise: exercise,
        exerciseIndex: exerciseIndex,
      ),
    );
  }
}
