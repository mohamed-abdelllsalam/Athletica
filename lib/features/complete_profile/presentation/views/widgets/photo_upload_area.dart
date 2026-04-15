import 'package:athletica/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhotoUploadArea extends StatelessWidget {
  const PhotoUploadArea({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: AppColors.textPrimary,
            borderRadius: 16.r,
          ),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.photo_library_rounded,
                color: AppColors.primaryAppColor,
                size: 28.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.borderRadius});

  final Color color;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final cornerLength = 40.0;

    // Top-left corner
    path.moveTo(0, cornerLength);
    path.lineTo(0, borderRadius);
    path.quadraticBezierTo(0, 0, borderRadius, 0);
    path.lineTo(cornerLength, 0);

    // Top-right corner
    path.moveTo(size.width - cornerLength, 0);
    path.lineTo(size.width - borderRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, borderRadius);
    path.lineTo(size.width, cornerLength);

    // Bottom-left corner
    path.moveTo(0, size.height - cornerLength);
    path.lineTo(0, size.height - borderRadius);
    path.quadraticBezierTo(0, size.height, borderRadius, size.height);
    path.lineTo(cornerLength, size.height);

    // Bottom-right corner
    path.moveTo(size.width - cornerLength, size.height);
    path.lineTo(size.width - borderRadius, size.height);
    path.quadraticBezierTo(
        size.width, size.height, size.width, size.height - borderRadius);
    path.lineTo(size.width, size.height - cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
