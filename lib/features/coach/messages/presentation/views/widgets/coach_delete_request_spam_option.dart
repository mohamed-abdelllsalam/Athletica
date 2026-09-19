import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachDeleteRequestSpamOption extends StatelessWidget {
  const CoachDeleteRequestSpamOption({
    super.key,
    required this.contactName,
    required this.markAsSpam,
    required this.onToggle,
  });
  final String contactName;
  final bool markAsSpam;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mark as Spam',
                  style: AppTextStyles.semiBold15(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Send Future messages from $contactName to spam',
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: markAsSpam
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary,
                  width: 2,
                ),
                color: markAsSpam ? AppColors.primaryBlue : Colors.transparent,
              ),
              child: markAsSpam
                  ? Icon(Icons.check, color: AppColors.textPrimary, size: 14.sp)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
