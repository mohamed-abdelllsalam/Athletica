import 'package:athletica/core/widgets/app_snack_bar.dart';
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
        bool copied;
        try {
          await Clipboard.setData(ClipboardData(text: message));
          feedback = 'Message copied';
          copied = true;
        } on PlatformException {
          feedback = 'Could not copy message. Please try again.';
          copied = false;
        }
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          copied
              ? AppSnackBar.success(content: Text(feedback))
              : AppSnackBar.error(content: Text(feedback)),
        );
      },
    );
  }
}
