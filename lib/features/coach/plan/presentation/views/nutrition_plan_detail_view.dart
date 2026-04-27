import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/nutrition_plan_detail_view_body.dart';
import 'package:flutter/material.dart';

class NutritionPlanDetailView extends StatelessWidget {
  const NutritionPlanDetailView({super.key, required this.plan});

  static const String routeName = 'nutrition-plan-detail';

  final NutritionPlan plan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(child: NutritionPlanDetailViewBody(plan: plan)),
    );
  }
}
