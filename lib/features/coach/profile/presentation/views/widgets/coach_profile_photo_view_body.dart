import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachProfilePhotoViewBody extends StatelessWidget {
  const CoachProfilePhotoViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 8.h),
            _buildAppBar(context),
            // Photo preview area (fills remaining space above the bottom sheet)
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppColors.primaryAppColor,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Placeholder image frame — replaced by a real image in production
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color(0xFF1A1A1A),
                      child: Icon(
                        Icons.person,
                        size: 120.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomSheet(context),
          ],
        ),
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
              'Profile photo',
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

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle pill
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Profile Photo',
            style: AppTextStyles.bold20(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _PhotoOptionButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () {},
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _PhotoOptionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoOptionButton extends StatelessWidget {
  const _PhotoOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.textTertiary, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 26.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: AppTextStyles.medium13(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
