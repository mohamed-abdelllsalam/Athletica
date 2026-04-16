import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachBarChart extends StatelessWidget {
  const CoachBarChart({super.key});

  static const List<double> _data = [
    0.85,
    0.72,
    0.50,
    0.62,
    0.45,
    0.68,
    0.58,
  ];
  static const List<String> _labels = [
    'Fri',
    'Sat',
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Today',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        height: 180.h,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double barAreaHeight = constraints.maxHeight - 28.h;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_data.length, (i) {
                return _buildBar(context, _data[i], _labels[i], barAreaHeight);
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBar(
    BuildContext context,
    double fraction,
    String label,
    double maxBarHeight,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 34.w,
          height: maxBarHeight * fraction,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: AppTextStyles.meduim12(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
