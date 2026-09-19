import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Owns its controller so it is disposed with the dialog route itself —
/// never dispose a dialog's controller right after `await showDialog`,
/// the exit animation still paints its TextField.
class WorkoutPlanAddDayDialog extends StatefulWidget {
  const WorkoutPlanAddDayDialog({
    super.key,
    required this.initialTitle,
    this.dialogTitle = 'Add Day',
    this.confirmLabel = 'Add',
  });

  final String initialTitle;
  final String dialogTitle;
  final String confirmLabel;

  @override
  State<WorkoutPlanAddDayDialog> createState() =>
      _WorkoutPlanAddDayDialogState();
}

class _WorkoutPlanAddDayDialogState extends State<WorkoutPlanAddDayDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      title: Text(
        widget.dialogTitle,
        style: AppTextStyles.semiBold14(
          context,
        ).copyWith(color: AppColors.textPrimary),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Day title'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
