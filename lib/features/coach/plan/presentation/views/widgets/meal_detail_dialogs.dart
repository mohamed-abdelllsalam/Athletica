import 'package:athletica/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CoachMealUnsavedChangesDialog extends StatelessWidget {
  const CoachMealUnsavedChangesDialog({
    super.key,
    required this.titleStyle,
    required this.bodyStyle,
    required this.onSave,
    required this.onSaveAndExit,
    required this.onDiscard,
  });
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
  final VoidCallback onSave;
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
          onPressed: onSave,
          child: Text(
            'Save',
            style: bodyStyle.copyWith(color: AppColors.primaryBlue),
          ),
        ),
        TextButton(
          onPressed: onSaveAndExit,
          child: Text(
            'Save and exit',
            style: bodyStyle.copyWith(color: Colors.white),
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

class CoachMealDeleteDialog extends StatelessWidget {
  const CoachMealDeleteDialog({
    super.key,
    required this.titleStyle,
    required this.bodyStyle,
    required this.onCancel,
    required this.onDelete,
  });
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      title: Text(
        'Delete meal?',
        style: titleStyle.copyWith(color: AppColors.textPrimary),
      ),
      content: Text(
        'This removes the meal and all of its foods.',
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
          onPressed: onDelete,
          child: Text('Delete', style: bodyStyle.copyWith(color: Colors.red)),
        ),
      ],
    );
  }
}
