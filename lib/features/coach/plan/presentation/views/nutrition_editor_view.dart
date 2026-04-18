import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/nutrition_editor_view_body.dart';
import 'package:flutter/material.dart';

class NutritionEditorView extends StatelessWidget {
  const NutritionEditorView({super.key, required this.clientName});

  final String clientName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(child: NutritionEditorViewBody(clientName: clientName)),
    );
  }
}
