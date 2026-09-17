import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/client_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachClientDetailAppBar extends StatelessWidget {
  const CoachClientDetailAppBar({
    super.key,
    required this.clientName,
    required this.onBack,
  });

  final String clientName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            clientName,
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class CoachClientProfileSection extends StatelessWidget {
  const CoachClientProfileSection({super.key, required this.client});

  final ClientProfile client;

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
            child: client.profileImage != null
                ? Image.network(client.profileImage!, fit: BoxFit.cover)
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
              client.displayName,
              style: AppTextStyles.bold20(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            SizedBox(height: 4.h),
            if (client.goal != null)
              Text(
                client.goal!,
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _StatItem(
                  label: 'Height',
                  value: '${client.heightCm ?? '--'} Cm',
                  context: context,
                ),
                SizedBox(width: 24.w),
                _StatItem(
                  label: 'Weight',
                  value: '${client.weightKg ?? '--'} Kg',
                  context: context,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class CoachClientMessageButton extends StatelessWidget {
  const CoachClientMessageButton({
    super.key,
    required this.clientName,
    required this.onPressed,
  });

  final String clientName;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Message ${clientName.split(' ').first}',
          style: AppTextStyles.semiBold15(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class CoachClientInformationButton extends StatelessWidget {
  const CoachClientInformationButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.surfaceDark, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Information',
              style: AppTextStyles.semiBold15(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Stat Item ----------

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
