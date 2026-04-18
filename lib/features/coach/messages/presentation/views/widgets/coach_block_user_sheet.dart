import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachBlockUserSheet extends StatelessWidget {
  const CoachBlockUserSheet({super.key, required this.contact});

  final ChatContact contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close,
                  color: AppColors.textPrimary, size: 24.sp),
            ),
          ),
          SizedBox(height: 12.h),
          CircleAvatar(
            radius: 36.r,
            backgroundColor: AppColors.surfaceDark,
            child: contact.imageAsset != null
                ? ClipOval(
                    child: Image.asset(contact.imageAsset!,
                        fit: BoxFit.cover, width: 72.r, height: 72.r),
                  )
                : Icon(Icons.person,
                    color: AppColors.textSecondary, size: 32.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            'Block ${contact.name} ?',
            style: AppTextStyles.bold20(context)
                .copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 24.h),
          _BlockInfoItem(
            icon: Icons.visibility_off_outlined,
            title: 'Unfriends them on Athletica',
            description:
                "If you're friends, blocking someone unfriends them and they can't find your profile .",
          ),
          SizedBox(height: 20.h),
          _BlockInfoItem(
            icon: Icons.person_off_outlined,
            title: 'Prevents unwanted contact',
            description: "They won't be able to message you.",
          ),
          SizedBox(height: 20.h),
          _BlockInfoItem(
            icon: Icons.remove_circle_outline,
            title: "They won't be notified",
            description:
                "We won't tell them if you block them. Unblocked from your privacy and safety settings.",
          ),
          SizedBox(height: 28.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Block ${contact.name}',
                style: AppTextStyles.semiBold15(context)
                    .copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockInfoItem extends StatelessWidget {
  const _BlockInfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 22.sp),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.semiBold15(context)
                    .copyWith(color: AppColors.textPrimary),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: AppTextStyles.meduim12(context)
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
