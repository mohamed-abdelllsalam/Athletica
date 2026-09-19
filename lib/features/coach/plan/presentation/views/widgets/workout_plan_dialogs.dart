import 'package:athletica/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachWorkoutPlanUnsavedChangesDialog extends StatelessWidget {
  const CoachWorkoutPlanUnsavedChangesDialog({
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

class CoachWorkoutPlanDeleteDayDialog extends StatelessWidget {
  const CoachWorkoutPlanDeleteDayDialog({
    super.key,
    required this.titleStyle,
    required this.bodyStyle,
    required this.onCancel,
    required this.onDelete,
    required this.dayTitle,
  });
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final String dayTitle;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      title: Text(
        'Delete day?',
        style: titleStyle.copyWith(color: AppColors.textPrimary),
      ),
      content: Text(
        'Remove "$dayTitle" and its exercises?',
        style: bodyStyle.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
        TextButton(
          onPressed: onDelete,
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

class CoachWorkoutPlanDeleteDialog extends StatelessWidget {
  const CoachWorkoutPlanDeleteDialog({
    super.key,
    required this.titleStyle,
    required this.bodyStyle,
    required this.onCancel,
    required this.onDelete,
    required this.templateTitle,
  });
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final String templateTitle;
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
        'This will permanently delete "$templateTitle" and cannot be undone.',
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
