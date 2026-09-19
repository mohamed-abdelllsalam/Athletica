import 'coach_profile_info_row.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachProfilePersonalInfo extends StatelessWidget {
  const CoachProfilePersonalInfo({
    super.key,
    required this.profile,
    required this.isLoggingOut,
    required this.onLogout,
  });
  final CoachProfileEntity profile;
  final bool isLoggingOut;
  final VoidCallback onLogout;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Info',
            style: AppTextStyles.bold20(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 14.h),
          CoachProfileInfoRow(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: profile.email,
          ),
          SizedBox(height: 14.h),
          CoachProfileInfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value:
                profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty
                ? profile.phoneNumber!
                : 'Not specified',
          ),
          SizedBox(height: 14.h),
          CoachProfileInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: profile.location != null && profile.location!.isNotEmpty
                ? profile.location!
                : 'Not specified',
          ),
          SizedBox(height: 14.h),
          CoachProfileInfoRow(
            icon: Icons.fitness_center_outlined,
            label: 'Specialization',
            value: profile.specialization.isNotEmpty
                ? profile.displayName(
                    Localizations.localeOf(context).languageCode,
                  )
                : 'Not specified',
          ),
          SizedBox(height: 24.h),
          if (profile.bio.isNotEmpty) ...[
            Text(
              'Bio',
              style: AppTextStyles.bold20(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            SizedBox(height: 10.h),
            Text(
              profile.bio,
              style: AppTextStyles.regular13(
                context,
              ).copyWith(color: AppColors.textSecondary, height: 1.6),
            ),
            SizedBox(height: 24.h),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isLoggingOut ? null : onLogout,
              icon: isLoggingOut
                  ? SizedBox(
                      width: 18.sp,
                      height: 18.sp,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                  : const Icon(Icons.logout_rounded, color: Colors.red),
              label: Text(
                'Sign Out',
                style: AppTextStyles.semiBold15(
                  context,
                ).copyWith(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}
