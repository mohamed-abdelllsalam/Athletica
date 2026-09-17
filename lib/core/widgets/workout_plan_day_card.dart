import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const List<Color> workoutPlanDayColors = [
  Color(0xFF3D2E8A),
  Color(0xFF2E5EA8),
  Color(0xFF2E8A4A),
  Color(0xFFB5541C),
  Color(0xFF6A2E8A),
  Color(0xFF1B6E6A),
];

class WorkoutPlanDayMenuAction {
  const WorkoutPlanDayMenuAction({
    required this.value,
    required this.label,
    required this.icon,
    this.danger = false,
  });

  final String value;
  final String label;
  final IconData icon;
  final bool danger;
}

class WorkoutPlanDayCard extends StatelessWidget {
  const WorkoutPlanDayCard({
    super.key,
    required this.dayLabel,
    required this.title,
    required this.subtitle,
    required this.isRest,
    required this.color,
    required this.onNavigate,
    required this.actions,
    required this.onMenuSelected,
  });

  final String dayLabel;
  final String title;
  final String subtitle;
  final bool isRest;
  final Color color;
  final VoidCallback onNavigate;
  final List<WorkoutPlanDayMenuAction> actions;
  final ValueChanged<String> onMenuSelected;

  @override
  Widget build(BuildContext context) {
    final iconColor = isRest ? AppColors.textTertiary : color;
    return GestureDetector(
      onTap: onNavigate,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isRest
              ? AppColors.cardBackground.withValues(alpha: 0.6)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: isRest
              ? Border.all(color: AppColors.textTertiary.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: isRest
                    ? Icon(Icons.bedtime, color: Colors.white, size: 20.sp)
                    : Text(
                        dayLabel,
                        style: AppTextStyles.semiBold14(
                          context,
                        ).copyWith(color: Colors.white),
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.medium14(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.meduim12(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
                size: 20.sp,
              ),
              padding: EdgeInsets.zero,
              color: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              onSelected: onMenuSelected,
              itemBuilder: (_) => [
                for (final action in actions)
                  PopupMenuItem(
                    value: action.value,
                    child: Row(
                      children: [
                        Icon(
                          action.icon,
                          size: 18,
                          color: action.danger
                              ? Colors.redAccent
                              : action.value == 'add'
                              ? AppColors.buttonColor
                              : AppColors.textSecondary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          action.label,
                          style: TextStyle(
                            color: action.danger ? Colors.redAccent : null,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
