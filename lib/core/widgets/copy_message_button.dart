import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyMessageButton extends StatelessWidget {
  const CopyMessageButton({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    if (message.trim().isEmpty) return const SizedBox.shrink();

    return IconButton(
      tooltip: 'Copy message',
      icon: const Icon(Icons.copy_rounded, size: 18),
      onPressed: () async {
        String feedback;
        try {
          await Clipboard.setData(ClipboardData(text: message));
          feedback = 'Message copied';
        } on PlatformException {
          feedback = 'Could not copy message. Please try again.';
        }
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(feedback)));
      },
    );
  }
}
