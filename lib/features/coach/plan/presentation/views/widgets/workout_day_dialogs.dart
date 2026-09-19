import 'package:athletica/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachWorkoutDayUnsavedChangesDialog extends StatelessWidget {
  const CoachWorkoutDayUnsavedChangesDialog({
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

class CoachWorkoutDayDeleteDialog extends StatelessWidget {
  const CoachWorkoutDayDeleteDialog({
    super.key,
    required this.titleStyle,
    required this.bodyStyle,
    required this.onCancel,
    required this.onDelete,
    required this.dayName,
  });
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final String dayName;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        'Delete day?',
        style: titleStyle.copyWith(color: AppColors.textPrimary),
      ),
      content: Text(
        'Remove "$dayName" and its exercises?',
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

class CoachWorkoutDayClearExercisesDialog extends StatelessWidget {
  const CoachWorkoutDayClearExercisesDialog({
    super.key,
    required this.titleStyle,
    required this.bodyStyle,
    required this.onCancel,
    required this.onClear,
  });
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
  final VoidCallback onCancel;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        'Clear All Exercises',
        style: titleStyle.copyWith(color: AppColors.textPrimary),
      ),
      content: Text(
        'Remove all exercises from this day?',
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
        TextButton(
          onPressed: onClear,
          child: Text(
            'Clear',
            style: bodyStyle.copyWith(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}
