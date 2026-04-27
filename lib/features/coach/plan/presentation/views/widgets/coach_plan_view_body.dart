import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/presentation/views/nutrition_plans_list_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/workout_plans_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CoachPlanViewBody extends StatelessWidget {
  const CoachPlanViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 28.h),
          Text(
            'My plans',
            style: AppTextStyles.bold24(context).copyWith(
              color: AppColors.textPrimary,
              fontSize: 28.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Choose What to manage',
            style: AppTextStyles.medium14(context).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          _PlanTypeCard(
            title: 'Workout',
            subtitle: 'Workouts & programs',
            stat1Label: 'Programs',
            stat1Value: '12',
            stat2Label: 'Active clients',
            stat2Value: '21',
            iconAsset: 'assets/images/plan/workout_icon.svg',
            gradient: const LinearGradient(
              colors: [Color(0xFF7B4FE8), Color(0xFF2E3A8C)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkoutPlansListView()),
            ),
          ),
          SizedBox(height: 20.h),
          _PlanTypeCard(
            title: 'Nutrition',
            subtitle: 'Meal Plan & Diets',
            stat1Label: 'Plans',
            stat1Value: '8',
            stat2Label: 'Active clients',
            stat2Value: '15',
            iconAsset: 'assets/images/plan/nutrition_icon.svg',
            gradient: const LinearGradient(
              colors: [Color(0xFFB22A4A), Color(0xFF5A0BFC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NutritionPlansListView()),
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

class _PlanTypeCard extends StatelessWidget {
  const _PlanTypeCard({
    required this.title,
    required this.subtitle,
    required this.stat1Label,
    required this.stat1Value,
    required this.stat2Label,
    required this.stat2Value,
    required this.iconAsset,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String stat1Label;
  final String stat1Value;
  final String stat2Label;
  final String stat2Value;
  final String iconAsset;
  final LinearGradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56.r,
                  height: 56.r,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: SvgPicture.asset(
                    iconAsset,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: AppTextStyles.bold24(context).copyWith(
                color: Colors.white,
                fontSize: 22.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: AppTextStyles.medium14(context).copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                _StatItem(label: stat1Label, value: stat1Value),
                SizedBox(width: 36.w),
                _StatItem(label: stat2Label, value: stat2Value),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.bold24(context).copyWith(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.meduim12(context).copyWith(
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
