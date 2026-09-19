import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';

class CoachContactProfileCard extends StatelessWidget {
  const CoachContactProfileCard({super.key, required this.contact});
  final ChatContact contact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50.r),
          child: Container(
            width: 90.r,
            height: 90.r,
            color: AppColors.surfaceDark,
            child: contact.imageAsset != null
                ? Image.asset(contact.imageAsset!, fit: BoxFit.cover)
                : Icon(
                    Icons.person,
                    color: AppColors.textSecondary,
                    size: 40.sp,
                  ),
          ),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.name,
              style: AppTextStyles.bold20(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            if (contact.heightCm != null || contact.weightKg != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  if (contact.heightCm != null)
                    _StatItem(
                      label: 'Height',
                      value: '${contact.heightCm} Cm',
                      context: context,
                    ),
                  if (contact.heightCm != null && contact.weightKg != null)
                    SizedBox(width: 24.w),
                  if (contact.weightKg != null)
                    _StatItem(
                      label: 'Weight',
                      value: '${contact.weightKg} Kg',
                      context: context,
                    ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.context,
  });

  final String label;
  final String value;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.meduim12(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
