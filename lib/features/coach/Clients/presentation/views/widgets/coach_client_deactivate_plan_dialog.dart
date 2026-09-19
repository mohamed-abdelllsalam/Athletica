import 'package:athletica/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CoachClientDeactivatePlanDialog extends StatelessWidget {
  const CoachClientDeactivatePlanDialog({
    super.key,
    required this.message,
    required this.onConfirm,
  });

  final String message;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      title: const Text(
        'Deactivate Plan',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text(
            'Deactivate',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
