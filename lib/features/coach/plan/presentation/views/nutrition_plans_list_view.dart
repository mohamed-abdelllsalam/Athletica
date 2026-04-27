import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/nutrition_plans_list_view_body.dart';
import 'package:flutter/material.dart';

class NutritionPlansListView extends StatelessWidget {
  const NutritionPlansListView({super.key});

  static const String routeName = 'nutrition-plans-list';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(child: NutritionPlansListViewBody()),
    );
  }
}
