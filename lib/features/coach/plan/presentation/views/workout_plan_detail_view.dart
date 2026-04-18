import 'package:athletica/features/coach/plan/domain/entities/workout_plan.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/workout_plan_detail_view_body.dart';
import 'package:flutter/material.dart';
import 'package:athletica/core/utils/app_colors.dart';

class WorkoutPlanDetailView extends StatelessWidget {
  const WorkoutPlanDetailView({super.key, required this.plan});

  static const String routeName = 'workout-plan-detail';

  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(child: WorkoutPlanDetailViewBody(plan: plan)),
    );
  }
}
