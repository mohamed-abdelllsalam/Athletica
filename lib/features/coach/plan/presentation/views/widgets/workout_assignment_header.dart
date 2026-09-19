import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachWorkoutAssignmentHeader extends StatelessWidget {
  const CoachWorkoutAssignmentHeader({
    super.key,
    required this.planName,
    required this.clientName,
    required this.onBack,
  });

  final VoidCallback onBack;
  final String planName;
  final String clientName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Customize Workout Assignment',
                  style: AppTextStyles.semiBold15(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '$planName  •  $clientName',
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
