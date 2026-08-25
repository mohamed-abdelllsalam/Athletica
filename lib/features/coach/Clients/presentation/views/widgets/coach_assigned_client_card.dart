import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_assigned_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachAssignedClientCard extends StatelessWidget {
  const CoachAssignedClientCard({
    super.key,
    required this.client,
    this.removing = false,
    this.onTap,
  });

  final CoachAssignedClient client;
  final bool removing;
  final VoidCallback? onTap;

  String get _initials {
    final parts =
        client.name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.map((p) => p[0].toUpperCase()).take(2).join();
  }

  String get _assignedLabel {
    final assignedAt = client.assignedAt;
    if (assignedAt == null) return 'Assigned client';
    return 'Assigned ${assignedAt.year}-${assignedAt.month.toString().padLeft(2, '0')}-${assignedAt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: removing ? 0.5 : 1,
      child: GestureDetector(
        onTap: removing ? null : onTap,
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
                      _assignedLabel,
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
                    if (client.email.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        client.email,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.meduim12(context).copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.flag_outlined,
                            color: AppColors.textSecondary, size: 14.sp),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            client.goal.isEmpty
                                ? 'No goal set'
                                : client.goal,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.semiBold14(context).copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                children: [
                  Container(
                    width: 56.r,
                    height: 56.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    child: Text(
                      _initials,
                      style: AppTextStyles.bold20(context)
                          .copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${client.heightCm ?? '--'} cm · ${client.weightKg ?? '--'} kg',
                    style: AppTextStyles.meduim11(context).copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
