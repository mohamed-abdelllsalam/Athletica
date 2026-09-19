import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachProfilePhotoOptions extends StatelessWidget {
  const CoachProfilePhotoOptions({
    super.key,
    required this.hasImage,
    required this.onCamera,
    required this.onGallery,
    required this.onDelete,
  });
  final bool hasImage;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
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
                  onTap: onCamera,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _PhotoOptionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: onGallery,
                ),
              ),
            ],
          ),
          if (hasImage) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: Text(
                  'Delete Photo',
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
          ],
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
