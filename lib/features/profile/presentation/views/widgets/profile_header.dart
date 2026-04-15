import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36.r,
            backgroundColor: AppColors.cardBackgroundLight,
            child: Icon(
              Icons.person,
              color: AppColors.textSecondary,
              size: 40.sp,
            ),
          ),
          SizedBox(width: 20.w),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    'Weight',
                    style: AppTextStyles.medium13(context).copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '74 Kg',
                    style: AppTextStyles.semiBold14(context).copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 24.w),
              Column(
                children: [
                  Text(
                    'Height',
                    style: AppTextStyles.medium13(context).copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '182 CM',
                    style: AppTextStyles.semiBold14(context).copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
