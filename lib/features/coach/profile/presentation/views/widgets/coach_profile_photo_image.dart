import 'package:athletica/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachProfilePhotoImage extends StatelessWidget {
  const CoachProfilePhotoImage({
    super.key,
    required this.profileImage,
    required this.isUploading,
  });
  final String? profileImage;
  final bool isUploading;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryAppColor,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isUploading)
            const CircularProgressIndicator(color: AppColors.primaryBlue)
          else if (profileImage != null && profileImage!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                profileImage!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFF1A1A1A),
                  child: Icon(
                    Icons.person,
                    size: 120.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
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
    );
  }
}
