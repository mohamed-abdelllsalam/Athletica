import 'package:athletica/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CoachAssignTemplatesHeader extends StatelessWidget {
  const CoachAssignTemplatesHeader({super.key, required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Select Template',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
