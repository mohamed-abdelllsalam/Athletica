import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachProfileHeader extends StatelessWidget {
  const CoachProfileHeader({super.key, required this.profile});
  final CoachProfileEntity profile;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 48.r,
            backgroundColor: AppColors.cardBackground,
            backgroundImage:
                profile.profileImage != null && profile.profileImage!.isNotEmpty
                ? NetworkImage(profile.profileImage!)
                : null,
            child: profile.profileImage == null || profile.profileImage!.isEmpty
                ? Icon(
                    Icons.person,
                    size: 48.sp,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),
          SizedBox(height: 14.h),
          Text(
            profile.name,
            style: AppTextStyles.bold24(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 4.h),
          Text(
            'Fitness Coach',
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
