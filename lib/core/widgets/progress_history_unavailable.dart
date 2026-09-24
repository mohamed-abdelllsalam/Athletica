import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class ProgressHistoryUnavailable extends StatelessWidget {
  const ProgressHistoryUnavailable({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      'Progress history is not available yet.',
      textAlign: TextAlign.center,
      style: AppTextStyles.medium14(
        context,
      ).copyWith(color: AppColors.textSecondary),
    ),
  );
}
