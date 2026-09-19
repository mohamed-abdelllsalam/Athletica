import 'package:athletica/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';

class CoachAssignTemplateCard extends StatelessWidget {
  const CoachAssignTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
  });
  final NutritionPlan template;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.cardBackground,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.receipt_long, color: AppColors.primaryBlue),
        ),
        title: Text(
          template.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          template.description,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: const Icon(
          Icons.add_circle_outline,
          color: AppColors.primaryBlue,
        ),
        onTap: onTap,
      ),
    );
  }
}
