import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/client_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachWorkoutAssignmentClientAvatar extends StatelessWidget {
  const CoachWorkoutAssignmentClientAvatar({
    super.key,
    required this.name,
    required this.profileImage,
    required this.isSelected,
    required this.onTap,
  });
  final String name;
  final String? profileImage;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ClientProfileAvatar(
            imageUrl: profileImage,
            size: 48.r,
            backgroundColor: AppColors.surfaceDark,
            placeholderColor: AppColors.textSecondary,
            borderColor: isSelected ? AppColors.buttonColor : null,
            borderWidth: 2,
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: 64.w,
            child: Text(
              name.split(' ').first,
              style: AppTextStyles.meduim11(
                context,
              ).copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class CoachWorkoutAssignmentActivePlan extends StatelessWidget {
  const CoachWorkoutAssignmentActivePlan({
    super.key,
    required this.title,
    required this.onTap,
  });
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}
