import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/meal_detail_view_body.dart';
import 'package:flutter/material.dart';

class MealDetailView extends StatelessWidget {
  const MealDetailView({super.key, required this.meal});

  static const String routeName = 'meal-detail';

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(child: MealDetailViewBody(meal: meal)),
    );
  }
}
