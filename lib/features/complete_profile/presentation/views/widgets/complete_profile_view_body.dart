import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/complete_profile/presentation/views/widgets/photo_upload_area.dart';
import 'package:athletica/features/home/presentation/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompleteProfileViewBody extends StatelessWidget {
  const CompleteProfileViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 32.h),
                Image.asset('assets/images/logo.png', height: 80.h),
                SizedBox(height: 8.h),
                Text(
                  'ATHLETICA',
                  style: AppTextStyles.extraBold30(
                    context,
                  ).copyWith(color: AppColors.primaryBlue, letterSpacing: 2),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Upload Your Photo',
                  style: AppTextStyles.bold24(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(height: 24.h),
                const PhotoUploadArea(),
                SizedBox(height: 24.h),
                SizedBox(
                  width: 160.w,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'Uploaded',
                      style: AppTextStyles.semiBold14(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Type Your Aage',
                    style: AppTextStyles.medium14(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Your Aage ...!',
                    hintStyle: AppTextStyles.medium14(
                      context,
                    ).copyWith(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        HomeView.routeName,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      'Done',
                      style: AppTextStyles.semiBold15(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
