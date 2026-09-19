import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachEditProfileAppBar extends StatelessWidget {
  const CoachEditProfileAppBar({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
          Expanded(
            child: Text(
              'Edit Profile',
              textAlign: TextAlign.center,
              style: AppTextStyles.bold20(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
          SizedBox(width: 20.sp),
        ],
      ),
    );
  }
}

class CoachEditProfileAvatar extends StatelessWidget {
  const CoachEditProfileAvatar({
    super.key,
    required this.profileImage,
    required this.onTap,
  });

  final String? profileImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: 46.r,
          backgroundColor: AppColors.cardBackground,
          backgroundImage: profileImage != null && profileImage!.isNotEmpty
              ? NetworkImage(profileImage!)
              : null,
          child: profileImage == null || profileImage!.isEmpty
              ? Icon(Icons.person, size: 46.sp, color: AppColors.textSecondary)
              : null,
        ),
      ),
    );
  }
}
