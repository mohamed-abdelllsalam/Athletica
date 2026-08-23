import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/meal_detail_view_body.dart';
import 'package:flutter/material.dart';

class MealDetailView extends StatelessWidget {
  const MealDetailView({
    super.key,
    required this.meal,
    this.onDelete,
    this.onPersist,
  });

  static const String routeName = 'meal-detail';

  final Meal meal;

  /// When provided, a delete action is shown in the meal header. The
  /// callback decides what deletion means (local removal in create mode,
  /// backend DELETE for persisted templates).
  final VoidCallback? onDelete;

  /// Persists edits without leaving the screen (saved templates only).
  final Future<void> Function(Meal meal)? onPersist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: MealDetailViewBody(
          meal: meal,
          onDelete: onDelete,
          onPersist: onPersist,
        ),
      ),
    );
  }
}
