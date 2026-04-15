import 'package:flutter/material.dart';

SlideTransition buildLogo(
  AnimationController controller,
  Animation<double> scaleAnim,
  Animation<double> rotationAnim,
) {
  final slideLeft =
      Tween<Offset>(
        begin: Offset(0.5, 0.0),
        end: const Offset(0.0, 0.0),
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.6, 0.8, curve: Curves.easeInOut),
        ),
      );

  return SlideTransition(
    position: slideLeft,
    child: Transform.rotate(
      angle: rotationAnim.value,
      child: Transform.scale(
        scale: scaleAnim.value,
        child: SizedBox(
          height: 60,
          child: Image.asset('assets/icons/icon.png', fit: BoxFit.contain),
        ),
      ),
    ),
  );
}
