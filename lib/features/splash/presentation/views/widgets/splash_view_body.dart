import 'dart:async';
import 'dart:math' as math;

import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/home/presentation/views/coach_home_view.dart';
import 'package:athletica/features/home/presentation/views/home_view.dart';
import 'package:athletica/features/on_boarding/presentation/views/on_boarding_view.dart';
import 'package:flutter/material.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody>
    with TickerProviderStateMixin {
  static const String _appName = 'Athletica';
  static const Duration _animationDuration = Duration(milliseconds: 1000);
  static const Duration _typeInterval = Duration(milliseconds: 100);

  late final AnimationController _controller;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _logoScale;
  Timer? _typeTimer;
  Timer? _navigateTimer;
  int _visibleChars = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _logoSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _logoScale = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleAnimationComplete();
      }
    });

    _controller.forward();
  }

  void _startTypewriter() {
    _typeTimer?.cancel();
    _typeTimer = Timer.periodic(_typeInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_visibleChars >= _appName.length) {
        timer.cancel();
        return;
      }

      setState(() {
        _visibleChars = math.min(_visibleChars + 1, _appName.length);
      });
    });
  }

  void _handleAnimationComplete() {
    _startTypewriter();
    final remainingChars = math.max(0, _appName.length - _visibleChars);
    final remainingMs = remainingChars * _typeInterval.inMilliseconds;
    final totalDelay = Duration(milliseconds: remainingMs + 1500);
    _navigateTimer?.cancel();
    _navigateTimer = Timer(totalDelay, () async {
      if (!mounted) return;
      final token = await TokenStorageService.instance.getToken();
      if (!mounted) return;
      if (token != null) {
        final role = await TokenStorageService.instance.getRole();
        if (!mounted) return;
        final route = role == 'TRAINER'
            ? CoachHomeView.routeName
            : HomeView.routeName;
        Navigator.pushReplacementNamed(context, route);
      } else {
        Navigator.pushReplacementNamed(context, OnBoardingView.routeName);
      }
    });
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _navigateTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final minDimension = math.min(size.width, size.height);
    final logoSize = minDimension * 0.25;
    final targetDy = (minDimension * 0.06).clamp(30.0, 40.0).toDouble();
    final visibleText = _appName.substring(0, _visibleChars);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _logoSlide,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0.0, _logoSlide.value.dy * targetDy),
                    child: child,
                  );
                },
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Image.asset(
                    'assets/icons/icon.png',
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                visibleText,
                textAlign: TextAlign.center,
                style: AppTextStyles.extraBold45(
                  context,
                ).copyWith(color: const Color(0xFF4C0DFD)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
