import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Client's assigned plans section on the profile screen.
///
/// Renders the real assigned workout/nutrition summaries from
/// [ClientProfileEntity]; honest empty placeholders when none are assigned;
/// a loading indicator while the profile itself is still loading.
class ProfileAssignedPlansSection extends StatelessWidget {
  const ProfileAssignedPlansSection({super.key, required this.profile});

  final ClientProfileEntity? profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned Plan',
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 12.h),
        if (profile == null)
          const Center(child: CircularProgressIndicator())
        else ...[
          Builder(
            builder: (context) {
              final title = profile!.workoutPlan?.title;
              if (title == null || title.isEmpty) {
                return const _EmptyPlanRow(
                  label: 'No workout plan assigned yet',
                );
              }
              final description = profile!.workoutPlan!.description;
              return _PlanCard(
                iconData: Icons.fitness_center,
                iconBgColor: AppColors.primaryBlue,
                title: title,
                subtitle: description.isNotEmpty
                    ? description
                    : 'Workout Plan',
              );
            },
          ),
          SizedBox(height: 10.h),
          Builder(
            builder: (context) {
              final title = profile!.nutritionPlan?.title;
              if (title == null || title.isEmpty) {
                return const _EmptyPlanRow(
                  label: 'No nutrition plan assigned yet',
                );
              }
              final description = profile!.nutritionPlan!.description;
              return _PlanCard(
                iconData: Icons.receipt_long,
                iconBgColor: AppColors.streakGreen,
                title: title,
                subtitle: description.isNotEmpty
                    ? description
                    : 'Nutrition Plan',
              );
            },
          ),
          SizedBox(height: 10.h),
          _PlanCard(
            iconData: Icons.emoji_events,
            iconBgColor: AppColors.streakFire,
            title: 'Fitness Goal',
            subtitle: profile!.goal ?? '—',
          ),
        ],
      ],
    );
  }
}

class _EmptyPlanRow extends StatelessWidget {
  const _EmptyPlanRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.meduim12(
          context,
        ).copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.iconData,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
  });

  final IconData iconData;
  final Color iconBgColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: iconBgColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(iconData, color: iconBgColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.semiBold14(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
