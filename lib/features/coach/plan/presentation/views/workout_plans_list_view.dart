import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/workout_plans_list_view_body.dart';
import 'package:flutter/material.dart';

class WorkoutPlansListView extends StatelessWidget {
  const WorkoutPlansListView({super.key});

  static const String routeName = 'workout-plans-list';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(child: WorkoutPlansListViewBody()),
    );
  }
}
