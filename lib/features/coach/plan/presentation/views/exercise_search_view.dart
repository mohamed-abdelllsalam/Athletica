import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/exercise_search_view_body.dart';
import 'package:flutter/material.dart';

class ExerciseSearchView extends StatelessWidget {
  const ExerciseSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(child: ExerciseSearchViewBody()),
    );
  }
}
