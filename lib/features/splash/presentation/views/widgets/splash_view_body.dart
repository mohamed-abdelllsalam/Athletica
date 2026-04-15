import 'package:athletica/features/on_boarding/presentation/views/on_boarding_view.dart';
import 'package:athletica/features/splash/presentation/views/widgets/build_logo.dart';
import 'package:athletica/features/splash/presentation/views/widgets/build_text.dart';
import 'package:flutter/material.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  SplashViewBodyState createState() => SplashViewBodyState();
}

class SplashViewBodyState extends State<SplashViewBody>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _rotationAnim;
  late final Animation<Color?> _bgColor;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnim = _createScaleAnimation();
    _rotationAnim = _createRotationAnimation();
    _bgColor = _createBackgroundColorAnimation();

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacementNamed(context, OnBoardingView.routeName);
      }
    });
  }

  Animation<double> _createScaleAnimation() {
    return TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
    ]).animate(_controller);
  }

  Animation<double> _createRotationAnimation() {
    return TweenSequence([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 40),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.745,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.745,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 10,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 40),
    ]).animate(_controller);
  }

  Animation<Color?> _createBackgroundColorAnimation() {
    return ColorTween(begin: Colors.white, end: Colors.green[100]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: _controller.value > 0.6
                  ? const LinearGradient(
                      begin: Alignment(0.80, 0.18),
                      end: Alignment(0.37, 0.74),
                      colors: [Color(0xFFEAFBF1), Color(0xFFBEF3D2)],
                    )
                  : null,
              color: _bgColor.value,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildLogo(_controller, _scaleAnim, _rotationAnim),
                  const SizedBox(width: 5),
                  buildText(context, _controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
