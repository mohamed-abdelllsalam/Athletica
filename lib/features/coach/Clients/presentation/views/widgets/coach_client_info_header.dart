import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:athletica/features/coach/clients/domain/entities/client_detail.dart';

class CoachClientInfoHeader extends StatelessWidget {
  const CoachClientInfoHeader({super.key, required this.client});
  final ClientProfile client;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40.r),
                child: Container(
                  width: 60.r,
                  height: 60.r,
                  color: AppColors.surfaceDark,
                  child: client.profileImage != null
                      ? Image.network(client.profileImage!, fit: BoxFit.cover)
                      : Icon(
                          Icons.person,
                          color: AppColors.textSecondary,
                          size: 28.sp,
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.displayName,
                      style: AppTextStyles.semiBold15(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      client.email,
                      style: AppTextStyles.meduim12(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            children: [
              if (client.gender != null)
                _InfoChip(label: 'Gender', value: client.gender!),
              if (client.goal != null)
                _InfoChip(label: 'Goal', value: client.goal!),
              if (client.heightCm != null)
                _InfoChip(label: 'Height', value: '${client.heightCm} cm'),
              if (client.weightKg != null)
                _InfoChip(label: 'Weight', value: '${client.weightKg} kg'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.meduim12(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: AppTextStyles.meduim12(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
