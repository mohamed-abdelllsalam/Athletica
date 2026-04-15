import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: AppColors.cardBackgroundLight,
            child: Icon(
              Icons.person,
              color: AppColors.textSecondary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Ahmed Mohamed',
              style: AppTextStyles.semiBold15(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
          _buildIconButton(icon: Icons.mail_outline_rounded, badgeCount: 0),
          SizedBox(width: 8.w),
          _buildIconButton(
            icon: Icons.notifications_none_rounded,
            badgeCount: 2,
          ),
          SizedBox(width: 8.w),
          _buildIconButton(icon: Icons.settings_outlined, badgeCount: 0),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required int badgeCount}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20.sp),
        ),
        if (badgeCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: const BoxDecoration(
                color: AppColors.notificationBadge,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$badgeCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
