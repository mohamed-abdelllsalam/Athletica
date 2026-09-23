import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/messages/domain/entities/coach_message_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachMessageItem extends StatelessWidget {
  const CoachMessageItem({super.key, required this.message, this.onTap});

  final CoachMessagePreview message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26.r,
              backgroundColor: AppColors.surfaceDark,
              backgroundImage: message.imageUrl?.trim().isNotEmpty == true
                  ? NetworkImage(message.imageUrl!.trim())
                  : null,
              child: message.imageUrl?.trim().isNotEmpty == true
                  ? null
                  : message.imageAsset != null
                  ? ClipOval(
                      child: Image.asset(
                        message.imageAsset!,
                        fit: BoxFit.cover,
                        width: 52.r,
                        height: 52.r,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: AppColors.textSecondary,
                      size: 24.sp,
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.name,
                    style: AppTextStyles.semiBold15(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    message.preview,
                    style: AppTextStyles.meduim12(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.timeAgo,
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                ),
                if (message.unreadCount > 0) ...[
                  SizedBox(height: 4.h),
                  Container(
                    width: 22.r,
                    height: 22.r,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${message.unreadCount}',
                      style: AppTextStyles.semiBold10(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
