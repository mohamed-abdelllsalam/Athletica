import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';

class CoachContactLifestyleSection extends StatelessWidget {
  const CoachContactLifestyleSection({super.key, required this.contact});
  final ChatContact contact;

  @override
  Widget build(BuildContext context) {
    final items = <({String label, String value})>[
      if (contact.experience != null)
        (label: 'Experience', value: contact.experience!),
      if (contact.schedule != null)
        (label: 'Schedule', value: contact.schedule!),
      if (contact.nutrition != null)
        (label: 'Nutrition', value: contact.nutrition!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Life Style',
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 4.h),
        ...items.map(
          (item) => Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90.w,
                      child: Text(
                        item.label,
                        style: AppTextStyles.semiBold14(
                          context,
                        ).copyWith(color: AppColors.primaryBlue),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.value,
                        style: AppTextStyles.medium14(
                          context,
                        ).copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: AppColors.surfaceDark, height: 1, thickness: 1),
            ],
          ),
        ),
      ],
    );
  }
}
