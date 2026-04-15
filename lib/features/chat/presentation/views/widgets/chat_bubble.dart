import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.avatarVisible = false,
  });

  final String message;
  final bool isMe;
  final bool avatarVisible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe && avatarVisible) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.cardBackgroundLight,
              child: Icon(
                Icons.person,
                color: AppColors.textSecondary,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 8.w),
          ],
          if (!isMe && !avatarVisible) SizedBox(width: 40.w),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primaryBlue : AppColors.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft:
                      isMe ? Radius.circular(16.r) : Radius.circular(4.r),
                  bottomRight:
                      isMe ? Radius.circular(4.r) : Radius.circular(16.r),
                ),
              ),
              child: Text(
                message,
                style: AppTextStyles.medium14(context).copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
