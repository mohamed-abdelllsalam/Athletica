import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/workout_plans_list_view_body.dart';
import 'package:athletica/features/coach/workout_templates/presentation/cubits/save_workout_plan_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_templates_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutPlansListView extends StatelessWidget {
  const WorkoutPlansListView({super.key});

  static const String routeName = 'workout-plans-list';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<WorkoutTemplatesCubit>()..load()),
        BlocProvider(create: (_) => sl<SaveWorkoutPlanCubit>()),
      ],
      child: const Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        body: SafeArea(child: WorkoutPlansListViewBody()),
      ),
    );
  }
}
