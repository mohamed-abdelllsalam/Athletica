import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SummarySection extends StatefulWidget {
  const SummarySection({super.key});

  @override
  State<SummarySection> createState() => _SummarySectionState();
}

class _SummarySectionState extends State<SummarySection> {
  int _selectedTab = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: AppTextStyles.bold24(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 4.h),
          Text(
            'Friday 7 Nov',
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: 16.h),
          _buildTabToggle(context),
        ],
      ),
    );
  }

  Widget _buildTabToggle(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _buildTab(context, 'Workouts', 0),
          SizedBox(width: 4.w),
          _buildTab(context, "Nutrition's", 1),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, int index) {
    final bool isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isActive ? AppColors.activeTabBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.semiBold14(context).copyWith(
              color: isActive
                  ? AppColors.activeTabText
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
