import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';

class CoachMessageRequestItem extends StatelessWidget {
  const CoachMessageRequestItem({
    super.key,
    required this.contact,
    required this.onTap,
  });

  final ChatContact contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preview = contact.messages.isNotEmpty
        ? contact.messages.last.text
        : '';
    final time = contact.messages.isNotEmpty ? contact.messages.last.time : '';

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
              child: contact.imageAsset != null
                  ? ClipOval(
                      child: Image.asset(
                        contact.imageAsset!,
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
                    contact.name,
                    style: AppTextStyles.semiBold15(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    preview,
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
            Text(
              time,
              style: AppTextStyles.meduim12(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 22.r,
              height: 22.r,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${contact.messages.length}',
                style: AppTextStyles.semiBold10(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
