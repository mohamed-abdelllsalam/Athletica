import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachActiveClientsError extends StatelessWidget {
  const CoachActiveClientsError({
    super.key,
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: AppTextStyles.medium14(context).copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class CoachActiveClientsEmpty extends StatelessWidget {
  const CoachActiveClientsEmpty({super.key, required this.query});
  final String query;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        query.isEmpty ? 'No active clients yet' : 'No clients match "$query"',
        style: AppTextStyles.medium14(
          context,
        ).copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
