import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/profile/presentation/views/edit_profile_view.dart';
import 'package:athletica/features/profile/presentation/views/widgets/profile_header.dart';
import 'package:athletica/features/profile/presentation/views/widgets/profile_info_field.dart';
import 'package:athletica/features/profile/presentation/views/widgets/goals_section.dart';
import 'package:athletica/features/profile/presentation/views/widgets/session_history_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileViewBody extends StatelessWidget {
  const ProfileViewBody({super.key});

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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                    size: 24.sp,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              const ProfileHeader(),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Text(
                      'Edit Photo',
                      style: AppTextStyles.medium14(context).copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        EditProfileView.routeName,
                      ),
                      child: Text(
                        'Edit Profile',
                        style: AppTextStyles.medium14(context).copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ProfileInfoField(
                      label: 'Name :',
                      value: 'Ahmed Mohamed',
                    ),
                    SizedBox(height: 12.h),
                    const ProfileInfoField(
                      label: 'Email :',
                      value: 'mohamed12@gmail.com',
                    ),
                    SizedBox(height: 12.h),
                    const ProfileInfoField(
                      label: 'Age :',
                      value: '26 years old',
                    ),
                    SizedBox(height: 12.h),
                    const ProfileInfoField(
                      label: 'Number',
                      value: '01123456789',
                    ),
                    SizedBox(height: 24.h),
                    Divider(color: AppColors.textTertiary, thickness: 0.5),
                    SizedBox(height: 16.h),
                    const GoalsSection(),
                    SizedBox(height: 24.h),
                    Divider(color: AppColors.textTertiary, thickness: 0.5),
                    SizedBox(height: 16.h),
                    const SessionHistorySection(),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
