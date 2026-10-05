import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/copy_message_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.time,
  });

  final String message;
  final bool isMe;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primaryBlue : AppColors.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: isMe
                      ? Radius.circular(16.r)
                      : Radius.circular(4.r),
                  bottomRight: isMe
                      ? Radius.circular(4.r)
                      : Radius.circular(16.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message,
                    style: AppTextStyles.medium14(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                  CopyMessageButton(message: message),
                  SizedBox(height: 4.h),
                  Text(
                    time,
                    style: AppTextStyles.meduim12(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
