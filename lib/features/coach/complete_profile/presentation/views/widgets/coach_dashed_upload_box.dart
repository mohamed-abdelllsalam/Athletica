import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachDashedUploadBox extends StatelessWidget {
  const CoachDashedUploadBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onUploadTap,
    this.showSkip = false,
    this.onSkipTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onUploadTap;
  final bool showSkip;
  final VoidCallback? onSkipTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          painter: _DashedBorderPainter(color: AppColors.textTertiary),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold20(context)
                      .copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(height: 8.h),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regular13(context)
                      .copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: onUploadTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: AppColors.primaryAppColor,
                    shape: const StadiumBorder(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 10.h,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Upload',
                    style: AppTextStyles.semiBold14(context)
                        .copyWith(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showSkip) ...[
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: onSkipTap,
            child: Text(
              'Skip',
              style: AppTextStyles.medium14(context)
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  static const double _strokeWidth = 1.0;
  static const double _dashWidth = 6.0;
  static const double _dashSpace = 4.0;
  static const double _radius = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(_radius),
      ));

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + _dashWidth),
          paint,
        );
        distance += _dashWidth + _dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
