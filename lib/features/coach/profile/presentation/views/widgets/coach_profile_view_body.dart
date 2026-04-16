import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/home/presentation/views/widgets/coach_bottom_nav_bar.dart';
import 'package:athletica/features/coach/profile/presentation/views/coach_edit_profile_view.dart';
import 'package:athletica/features/coach/profile/presentation/views/widgets/coach_certificate_item.dart';
import 'package:athletica/features/coach/profile/presentation/views/widgets/coach_profile_info_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachProfileViewBody extends StatelessWidget {
  const CoachProfileViewBody({super.key});

  static const String _bio =
      'Passionate strength coach with 3+ years helping clients reach their fitness goals. Focused on motivation, discipline, and real results\nhelping busy people get strong, fit, and confident through customized plans .';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              _buildAppBar(context),
              SizedBox(height: 20.h),
              _buildProfileHeader(context),
              SizedBox(height: 24.h),
              Padding(
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
                    const CoachProfileInfoRow(
                      icon: Icons.mail_outline_rounded,
                      label: 'Email',
                      value: 'mohamed.12@gmail.com',
                    ),
                    SizedBox(height: 14.h),
                    const CoachProfileInfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: '+201012345678',
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Bio',
                      style: AppTextStyles.bold20(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      _bio,
                      style: AppTextStyles.regular13(
                        context,
                      ).copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Certificates',
                      style: AppTextStyles.bold20(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 14.h),
                    const CoachCertificateItem(
                      name: 'Certified HIIT Instructor',
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CoachBottomNavBar(
        selectedIndex: 3,
        onTap: (index) {
          if (index != 3) Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
          Expanded(
            child: Text(
              'Profile',
              textAlign: TextAlign.center,
              style: AppTextStyles.bold20(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, CoachEditProfileView.routeName),
            child: Icon(
              Icons.edit_outlined,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 48.r,
            backgroundColor: AppColors.cardBackground,
            child: Icon(
              Icons.person,
              size: 48.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'Mohamed Ahmed',
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
