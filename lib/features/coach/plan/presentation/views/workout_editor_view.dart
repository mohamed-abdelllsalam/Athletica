import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/workout_editor_view_body.dart';
import 'package:flutter/material.dart';

class WorkoutEditorView extends StatelessWidget {
  const WorkoutEditorView({super.key, required this.clientName});

  final String clientName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(child: WorkoutEditorViewBody(clientName: clientName)),
    );
  }
}
