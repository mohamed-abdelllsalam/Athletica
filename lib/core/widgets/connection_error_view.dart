import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The shared request-failure UI; never infers internet access from Wi-Fi.
class ConnectionErrorView extends StatelessWidget {
  const ConnectionErrorView({
    super.key,
    required this.onRetry,
    this.compact = false,
  });

  final VoidCallback onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: 20.w,
      vertical: compact ? 12.h : 32.h,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.wifi_off_rounded,
          color: AppColors.primaryPurple,
          size: compact ? 28.sp : 42.sp,
        ),
        SizedBox(height: 12.h),
        Text(
          'Connection error',
          textAlign: TextAlign.center,
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 8.h),
        Text(
          'No internet connection. Please check your connection and try again.',
          textAlign: TextAlign.center,
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 8.h),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

/// Displays a refresh failure above the affected section's confirmed data.
class ConnectionErrorSection extends StatelessWidget {
  const ConnectionErrorSection({
    super.key,
    required this.hasError,
    required this.onRetry,
    required this.child,
  });

  final bool hasError;
  final VoidCallback onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) => hasError
      ? Column(
          children: [
            ConnectionErrorView(onRetry: onRetry, compact: true),
            child,
          ],
        )
      : child;
}
