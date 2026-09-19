import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';

class CoachChatProfileHeader extends StatelessWidget {
  const CoachChatProfileHeader({
    super.key,
    required this.contact,
    required this.onOpenProfile,
  });
  final ChatContact contact;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8.h),
        CircleAvatar(
          radius: 56.r,
          backgroundColor: AppColors.surfaceDark,
          child: contact.imageAsset != null
              ? ClipOval(
                  child: Image.asset(
                    contact.imageAsset!,
                    fit: BoxFit.cover,
                    width: 112.r,
                    height: 112.r,
                  ),
                )
              : Icon(Icons.person, color: AppColors.textSecondary, size: 48.sp),
        ),
        SizedBox(height: 12.h),
        Text(
          contact.name,
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: onOpenProfile,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'View Profile',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
