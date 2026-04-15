import 'dart:math' as math;

import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/workout_session/presentation/cubits/rest_timer_cubit.dart';
import 'package:athletica/features/workout_session/presentation/cubits/rest_timer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showRestTimerSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.cardBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => BlocProvider(
      create: (_) => RestTimerCubit(),
      child: const _RestTimerSheet(),
    ),
  );
}

class _RestTimerSheet extends StatelessWidget {
  const _RestTimerSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row
          Row(
            children: [
              const Spacer(),
              Text(
                'Rest Timer',
                style: AppTextStyles.semiBold15(context)
                    .copyWith(color: AppColors.textPrimary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close,
                    color: AppColors.textSecondary, size: 20.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Add or subtract 15 seconds using the +/- buttons',
            style: AppTextStyles.medium13(context)
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          // Circular timer + adjust buttons
          BlocBuilder<RestTimerCubit, RestTimerState>(
            builder: (context, state) {
              final cubit = context.read<RestTimerCubit>();
              final progress = state.total.inSeconds > 0
                  ? state.remaining.inSeconds / state.total.inSeconds
                  : 0.0;
              final mm = state.remaining.inMinutes
                  .remainder(60)
                  .toString()
                  .padLeft(2, '0');
              final ss = state.remaining.inSeconds
                  .remainder(60)
                  .toString()
                  .padLeft(2, '0');

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => cubit.adjustSeconds(-15),
                    child: Text(
                      '-15s',
                      style: AppTextStyles.medium14(context)
                          .copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                  SizedBox(
                    width: 150.w,
                    height: 150.w,
                    child: CustomPaint(
                      painter: _ArcPainter(progress: progress.clamp(0.0, 1.0)),
                      child: Center(
                        child: Text(
                          '$mm:$ss',
                          style: AppTextStyles.bold24(context)
                              .copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => cubit.adjustSeconds(15),
                    child: Text(
                      '+15s',
                      style: AppTextStyles.medium14(context)
                          .copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 32.h),
          // Pause / Skip buttons
          BlocBuilder<RestTimerCubit, RestTimerState>(
            builder: (context, state) {
              final cubit = context.read<RestTimerCubit>();
              final isPaused = state is RestTimerPaused;
              final isDone = state is RestTimerDone;

              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isDone ? null : cubit.togglePause,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.textPrimary,
                        disabledBackgroundColor: AppColors.textTertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        isPaused ? 'Resume' : 'Pause',
                        style: AppTextStyles.semiBold14(context)
                            .copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isDone
                          ? () => Navigator.pop(context)
                          : cubit.skip,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(
                            color: AppColors.textSecondary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        isDone ? 'Close' : 'Skip',
                        style: AppTextStyles.semiBold14(context)
                            .copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 8.0;

    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.cardBackgroundLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc (clockwise from top, shrinks as time elapses)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = AppColors.primaryBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}
