import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';

class CoachChatSecurityNotice extends StatelessWidget {
  const CoachChatSecurityNotice({super.key, required this.contact});
  final ChatContact contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lock_outline,
                color: AppColors.textSecondary,
                size: 14.sp,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.meduim12(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                    children: [
                      const TextSpan(
                        text:
                            'Messages are now secured with end-to-end encryption. Only people is this chat can read, listen to, or share them. ',
                      ),
                      TextSpan(
                        text: 'Learn more',
                        style: AppTextStyles.meduim12(
                          context,
                        ).copyWith(color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'If you accept ${contact.name} will be able to message you and may see info like your active status and when you\'ve read message',
            style: AppTextStyles.meduim12(
              context,
            ).copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
