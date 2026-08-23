import 'package:flutter/material.dart';

/// Dismisses the keyboard when the user taps anywhere in empty space.
/// Wrap a screen's body with this; child widgets keep receiving their own
/// taps normally.
class UnfocusOnTap extends StatelessWidget {
  const UnfocusOnTap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
