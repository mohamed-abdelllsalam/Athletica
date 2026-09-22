import 'package:athletica/core/widgets/check_ins/check_in_ui.dart';
import 'package:flutter/material.dart';

class StatusMessage extends StatelessWidget {
  const StatusMessage({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: CheckInUi.text(13),
              ),
              if (onRetry != null)
                TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
}
