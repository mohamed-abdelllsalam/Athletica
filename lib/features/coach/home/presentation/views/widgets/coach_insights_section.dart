import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/home/presentation/views/widgets/coach_bar_chart.dart';
import 'package:athletica/features/coach/home/presentation/views/widgets/coach_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachInsightsSection extends StatelessWidget {
  const CoachInsightsSection({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  final int selectedPeriod;
  final ValueChanged<int> onPeriodChanged;

  static const List<String> _periodLabels = ['Daily', 'Monthly'];
  static const List<String> _percentages = ['+5 %', '+15 %'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Insights',
            style: AppTextStyles.bold24(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Client Engagement',
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
        ),
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            _percentages[selectedPeriod],
            style: AppTextStyles.bold24(
              context,
            ).copyWith(color: AppColors.streakBlue),
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _PeriodToggle(
            selectedPeriod: selectedPeriod,
            onPeriodChanged: onPeriodChanged,
            labels: _periodLabels,
          ),
        ),
        SizedBox(height: 20.h),
        selectedPeriod == 0 ? const CoachBarChart() : const CoachLineChart(),
      ],
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.labels,
  });

  final int selectedPeriod;
  final ValueChanged<int> onPeriodChanged;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          return Expanded(child: _buildTab(context, labels[i], i));
        }),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, int index) {
    final bool isActive = selectedPeriod == index;
    return GestureDetector(
      onTap: () => onPeriodChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.semiBold14(context).copyWith(
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
