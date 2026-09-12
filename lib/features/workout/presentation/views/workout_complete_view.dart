import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class WorkoutCompleteView extends StatefulWidget {
  const WorkoutCompleteView({super.key});

  static const String animationAsset =
      'assets/animations/workout_complete.json';

  @override
  State<WorkoutCompleteView> createState() => _WorkoutCompleteViewState();
}

class _WorkoutCompleteViewState extends State<WorkoutCompleteView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _canFinish = false;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _canFinish = true);
    }
  }

  void _handleLoadFailure() {
    if (_loadFailed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _loadFailed) return;
      setState(() {
        _loadFailed = true;
        _canFinish = true;
      });
    });
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_onAnimationStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
          child: Column(
            children: [
              const Spacer(),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 420.w),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Lottie.asset(
                    WorkoutCompleteView.animationAsset,
                    controller: _controller,
                    repeat: false,
                    fit: BoxFit.contain,
                    onLoaded: (composition) {
                      _controller
                        ..duration = composition.duration
                        ..forward(from: 0);
                    },
                    errorBuilder: (context, error, stackTrace) {
                      _handleLoadFailure();
                      return Center(
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppColors.primaryPurple,
                          size: 88.sp,
                          semanticLabel: 'Workout complete',
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (_loadFailed)
                Text(
                  'Workout complete',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold20(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
              const Spacer(),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _canFinish ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !_canFinish,
                  child: SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'Done',
                        style: AppTextStyles.semiBold15(
                          context,
                        ).copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
