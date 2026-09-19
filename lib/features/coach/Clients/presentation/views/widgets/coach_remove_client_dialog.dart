import 'package:athletica/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachRemoveClientDialog extends StatelessWidget {
  const CoachRemoveClientDialog({
    super.key,
    required this.clientName,
    required this.titleStyle,
    required this.bodyStyle,
    required this.onCancel,
    required this.onConfirm,
  });
  final String clientName;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text('Remove client?', style: titleStyle),
      content: Text(
        '$clientName and all their plan data will be removed from your roster.',
        style: bodyStyle,
      ),
      actions: [
        TextButton(
          onPressed: () => onCancel(),
          child: Text('Cancel', style: bodyStyle),
        ),
        ElevatedButton(
          onPressed: () => onConfirm(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF5252),
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          child: const Text('Remove'),
        ),
      ],
    );
  }
}
