import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';

class CoachChatBubble extends StatelessWidget {
  const CoachChatBubble({
    super.key,
    required this.message,
    required this.contact,
  });

  final ChatMessage message;
  final ChatContact contact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: message.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.surfaceDark,
              child: contact.imageAsset != null
                  ? ClipOval(
                      child: Image.asset(
                        contact.imageAsset!,
                        fit: BoxFit.cover,
                        width: 32.r,
                        height: 32.r,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: AppColors.textSecondary,
                      size: 16.sp,
                    ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: message.isMe
                    ? AppColors.primaryBlue
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: message.isMe
                      ? Radius.circular(16.r)
                      : Radius.circular(4.r),
                  bottomRight: message.isMe
                      ? Radius.circular(4.r)
                      : Radius.circular(16.r),
                ),
              ),
              child: Text(
                message.text,
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
          if (message.isMe) ...[
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.surfaceDark,
              child: Icon(
                Icons.person,
                color: AppColors.textSecondary,
                size: 16.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
