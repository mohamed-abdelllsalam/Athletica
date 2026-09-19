import 'package:flutter/material.dart';

class CoachAssignTemplatesError extends StatelessWidget {
  const CoachAssignTemplatesError({
    super.key,
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class CoachAssignTemplatesEmpty extends StatelessWidget {
  const CoachAssignTemplatesEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No templates available.\nCreate a template first to assign a plan.',
        textAlign: TextAlign.center,
      ),
    );
  }
}
