import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.textPrimary,
              size: 24.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.medium16(context).copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
