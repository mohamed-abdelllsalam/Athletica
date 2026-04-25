import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachClientCard extends StatelessWidget {
  const CoachClientCard({
    super.key,
    required this.client,
    this.onTap,
    this.showPercent = false,
  });

  final CoachClient client;
  final VoidCallback? onTap;
  final bool showPercent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Joined ${client.joinedMonthsAgo} months ago',
                    style: AppTextStyles.meduim12(context).copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    client.name,
                    style: AppTextStyles.bold20(context).copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        'Subscription : ',
                        style: AppTextStyles.meduim12(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        client.subscriptionActive
                            ? 'Active${showPercent && client.subscriptionPercent != null ? ' ${client.subscriptionPercent}%' : ''}'
                            : 'Inactive',
                        style: AppTextStyles.semiBold14(context).copyWith(
                          color: client.subscriptionActive
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF5252),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                width: 80.r,
                height: 80.r,
                color: AppColors.surfaceDark,
                child: client.imageAsset != null
                    ? Image.asset(client.imageAsset!, fit: BoxFit.cover)
                    : Icon(
                        Icons.person,
                        color: AppColors.textSecondary,
                        size: 36.sp,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
