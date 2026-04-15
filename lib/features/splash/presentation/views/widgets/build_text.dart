import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

SlideTransition buildText(
  BuildContext context,
  AnimationController controller,
) {
  return SlideTransition(
    position: Tween<Offset>(begin: const Offset(-0.5, 0.0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.8, 0.95, curve: Curves.easeOut),
          ),
        ),
    child: FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: const Interval(0.85, 1.0)),
      ),
      child: Text(
        'ATHLETICA',
        style: AppTextStyles.extraBold30(
          context,
        ).copyWith(color: const Color(0xFF23AC58)),
      ),
    ),
  );
}
