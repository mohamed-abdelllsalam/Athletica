import 'package:athletica/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachNutritionPlanUnsavedChangesDialog extends StatelessWidget {
  const CoachNutritionPlanUnsavedChangesDialog({
    super.key,
    required this.titleStyle,
    required this.bodyStyle,
    required this.onSaveAndExit,
    required this.onDiscard,
  });
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
  final VoidCallback onSaveAndExit;
  final VoidCallback onDiscard;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      title: Text(
        'Unsaved changes',
        style: titleStyle.copyWith(color: AppColors.textPrimary),
      ),
      content: Text(
        'Do you want to save your changes before leaving?',
        style: bodyStyle.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: onSaveAndExit,
          child: Text(
            'Save and exit',
            style: bodyStyle.copyWith(color: AppColors.primaryBlue),
          ),
        ),
        TextButton(
          onPressed: onDiscard,
          child: Text('Discard', style: bodyStyle.copyWith(color: Colors.red)),
        ),
      ],
    );
  }
}

class CoachNutritionPlanDeleteDialog extends StatelessWidget {
  const CoachNutritionPlanDeleteDialog({
    super.key,
    required this.titleStyle,
    required this.bodyStyle,
    required this.onCancel,
    required this.onDelete,
    required this.clientCount,
  });
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final int clientCount;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        'Delete template?',
        style: titleStyle.copyWith(color: AppColors.textPrimary),
      ),
      content: Text(
        clientCount > 0
            ? 'This template is assigned to $clientCount client(s). '
                  'You must remove all assigned plans first before deleting.'
            : 'This will permanently delete this template and cannot be undone.',
        style: bodyStyle.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Cancel',
            style: bodyStyle.copyWith(color: AppColors.textSecondary),
          ),
        ),
        if (clientCount == 0)
          ElevatedButton(
            onPressed: onDelete,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: const Text('Delete'),
          ),
      ],
    );
  }
}
