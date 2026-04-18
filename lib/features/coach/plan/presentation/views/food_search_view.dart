import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/food_search_view_body.dart';
import 'package:flutter/material.dart';

class FoodSearchView extends StatelessWidget {
  const FoodSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(child: FoodSearchViewBody()),
    );
  }
}
