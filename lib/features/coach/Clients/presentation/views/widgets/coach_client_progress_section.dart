import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/client_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachClientProgressSection extends StatelessWidget {
  const CoachClientProgressSection({
    super.key,
    required this.detail,
    required this.tabs,
    required this.selectedIndex,
    required this.dataPoints,
    required this.xLabels,
    required this.onTabSelected,
  });

  final ClientDetail detail;
  final List<String> tabs;
  final int selectedIndex;
  final List<double> dataPoints;
  final List<String> xLabels;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Overview',
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 12.h),
        _StreakRow(
          title: 'Nutrition Streak',
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFF5ED1A0),
          currentStreak: detail.nutritionStreak.current,
          lastDate: detail.nutritionStreak.lastDate,
        ),
        SizedBox(height: 10.h),
        _StreakRow(
          title: 'Workout Streak',
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFFB76CFF),
          currentStreak: detail.workoutStreak.current,
          lastDate: detail.workoutStreak.lastDate,
          showLastDate: false,
        ),
        SizedBox(height: 16.h),
        _TabSelector(
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected,
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 200.h,
          child: _LineChart(dataPoints: dataPoints, xLabels: xLabels),
        ),
      ],
    );
  }
}

class _StreakRow extends StatelessWidget {
  const _StreakRow({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.currentStreak,
    required this.lastDate,
    this.showLastDate = true,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final int currentStreak;
  final String? lastDate;
  final bool showLastDate;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      if (i == 6) return 'Today';
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    });

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.semiBold14(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
                    if (showLastDate && lastDate != null)
                      Text(
                        'Last: $lastDate',
                        style: AppTextStyles.meduim11(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(days.length, (index) {
                    final isDone = index < currentStreak;
                    return Column(
                      children: [
                        Container(
                          width: 24.r,
                          height: 24.r,
                          decoration: BoxDecoration(
                            color: isDone
                                ? iconColor.withValues(alpha: 0.18)
                                : Colors.transparent,
                            border: Border.all(
                              color: isDone
                                  ? iconColor
                                  : AppColors.textSecondary.withValues(
                                      alpha: 0.65,
                                    ),
                              width: 1.3,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDone ? Icons.check_rounded : Icons.close_rounded,
                            size: 14.sp,
                            color: isDone ? iconColor : AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          days[index],
                          style: AppTextStyles.meduim11(
                            context,
                          ).copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: Container(
                margin: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[index],
                  style: AppTextStyles.medium14(context).copyWith(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---------- Line Chart ----------

class _LineChart extends StatelessWidget {
  const _LineChart({required this.dataPoints, required this.xLabels});

  final List<double> dataPoints;
  final List<String> xLabels;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(dataPoints: dataPoints, xLabels: xLabels),
      child: const SizedBox.expand(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.dataPoints, required this.xLabels});

  final List<double> dataPoints;
  final List<String> xLabels;

  static const _yLabels = ['100%', '75%', '50%', '25%', '0%'];
  static const _leftPad = 44.0;
  static const _bottomPad = 22.0;
  static const _rightPad = 8.0;
  static const _topPad = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final chartW = size.width - _leftPad - _rightPad;
    final chartH = size.height - _topPad - _bottomPad;

    final gridPaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 1;

    for (int i = 0; i < _yLabels.length; i++) {
      final ratio = i / (_yLabels.length - 1);
      final y = _topPad + chartH * ratio;
      canvas.drawLine(
        Offset(_leftPad, y),
        Offset(_leftPad + chartW, y),
        gridPaint,
      );
      _paintText(
        canvas,
        _yLabels[i],
        Offset(0, y - 7),
        const Color(0xFF9E9E9E),
        9.5,
      );
    }

    if (dataPoints.length < 2) return;

    // Gradient fill under the line
    final fillPath = Path();
    for (int i = 0; i < dataPoints.length; i++) {
      final x = _leftPad + chartW * i / (dataPoints.length - 1);
      final y = _topPad + chartH * (1 - dataPoints[i]);
      if (i == 0) {
        fillPath.moveTo(x, y);
      } else {
        final prevX = _leftPad + chartW * (i - 1) / (dataPoints.length - 1);
        final prevY = _topPad + chartH * (1 - dataPoints[i - 1]);
        final cpX = prevX + (x - prevX) / 2;
        fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }
    fillPath.lineTo(_leftPad + chartW, _topPad + chartH);
    fillPath.lineTo(_leftPad, _topPad + chartH);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF5273E0).withValues(alpha: 0.3),
            const Color(0xFF5273E0).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(_leftPad, _topPad, chartW, chartH)),
    );

    // Smooth bezier line
    final linePath = Path();
    for (int i = 0; i < dataPoints.length; i++) {
      final x = _leftPad + chartW * i / (dataPoints.length - 1);
      final y = _topPad + chartH * (1 - dataPoints[i]);
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        final prevX = _leftPad + chartW * (i - 1) / (dataPoints.length - 1);
        final prevY = _topPad + chartH * (1 - dataPoints[i - 1]);
        final cpX = prevX + (x - prevX) / 2;
        linePath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.streakPurple
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // X-axis labels
    _paintText(
      canvas,
      'Days',
      Offset(0, size.height - _bottomPad + 5),
      const Color(0xFF6B6B6B),
      9.0,
    );
    for (int i = 0; i < xLabels.length; i++) {
      final x = _leftPad + chartW * i / (xLabels.length - 1);
      _paintText(
        canvas,
        xLabels[i],
        Offset(x - xLabels[i].length * 2.8, size.height - _bottomPad + 5),
        const Color(0xFF9E9E9E),
        9.5,
      );
    }
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double fontSize,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.dataPoints != dataPoints || old.xLabels != xLabels;
}
