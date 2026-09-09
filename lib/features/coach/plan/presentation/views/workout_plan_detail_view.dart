import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_cubit.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/workout_plan_detail_view_body.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_plans_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_template_detail_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutPlanDetailView extends StatelessWidget {
  const WorkoutPlanDetailView({
    super.key,
    required this.program,
    this.isCreateMode = false,
  });

  static const String routeName = 'workout-plan-detail';

  final WorkoutProgram program;
  final bool isCreateMode;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<WorkoutTemplateDetailCubit>()..load(program.id),
        ),
        BlocProvider(create: (_) => sl<CoachClientsCubit>()..loadClients()),
        BlocProvider(create: (_) => sl<WorkoutPlansCubit>()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        body: SafeArea(
          child: WorkoutPlanDetailViewBody(
            program: program,
            isCreateMode: isCreateMode,
          ),
        ),
      ),
    );
  }
}
