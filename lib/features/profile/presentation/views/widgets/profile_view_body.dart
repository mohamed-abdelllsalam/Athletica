import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_state.dart';
import 'package:athletica/features/profile/presentation/views/edit_profile_view.dart';
import 'package:athletica/features/profile/presentation/views/profile_info_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileViewBody extends StatefulWidget {
  const ProfileViewBody({super.key});

  @override
  State<ProfileViewBody> createState() => _ProfileViewBodyState();
}

class _ProfileViewBodyState extends State<ProfileViewBody> {
  int _selectedTabIndex = 0;

  static const _tabs = ['Daily', 'Weekly', 'Monthly'];
  static const _dailyData = [0.80, 0.75, 0.45, 0.60, 0.75, 0.85, 0.95];
  static const _weeklyData = [0.50, 0.60, 0.70, 0.65, 0.80, 0.72, 0.90];
  static const _monthlyData = [0.30, 0.45, 0.55, 0.60, 0.70, 0.80, 0.85];
  static const _xLabels = ['Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Today'];

  List<double> get _currentData {
    switch (_selectedTabIndex) {
      case 1:
        return _weeklyData;
      case 2:
        return _monthlyData;
      default:
        return _dailyData;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _buildProfileSection(context),
                    SizedBox(height: 16.h),
                    _buildEditButtons(context),
                    SizedBox(height: 16.h),
                    _buildMessageCoachButton(context),
                    SizedBox(height: 12.h),
                    _buildInformationButton(context),
                    SizedBox(height: 24.h),
                    _buildAssignedPlanSection(context),
                    SizedBox(height: 24.h),
                    _buildProgressOverviewSection(context),
                    SizedBox(height: 8.h),
                    Divider(color: AppColors.surfaceDark, thickness: 1),
                    SizedBox(height: 8.h),
                    _buildSubscriptionInfoSection(context),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 8.w),
          BlocBuilder<ProfileCubit, ProfileState>(
            buildWhen: (prev, curr) =>
                curr is ProfileLoaded || curr is ProfileLoading,
            builder: (context, state) {
              final name =
                  state is ProfileLoaded ? state.profile.client.name : '...';
              return Text(
                name,
                style: AppTextStyles.semiBold15(context)
                    .copyWith(color: AppColors.textPrimary),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (prev, curr) =>
          curr is ProfileLoaded || curr is ProfileLoading,
      builder: (context, state) {
        final profile = state is ProfileLoaded ? state.profile : null;
        final name = profile?.client.name ?? '—';
        final imageUrl = profile?.client.profileImage;
        final height = profile?.heightCm != null
            ? '${profile!.heightCm} Cm'
            : '—';
        final weight = profile?.weightKg != null
            ? '${profile!.weightKg} Kg'
            : '—';

        return Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50.r),
              child: Container(
                width: 90.r,
                height: 90.r,
                color: AppColors.surfaceDark,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.person,
                          color: AppColors.textSecondary,
                          size: 40.sp,
                        ),
                      )
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
                  name,
                  style: AppTextStyles.bold20(context)
                      .copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _StatItem(
                      label: 'Height',
                      value: height,
                      context: context,
                    ),
                    SizedBox(width: 24.w),
                    _StatItem(
                      label: 'Weight',
                      value: weight,
                      context: context,
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.textSecondary, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            child: Text(
              'Edit Photo',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: OutlinedButton(
            onPressed: () =>
                Navigator.pushNamed(context, EditProfileView.routeName),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.textSecondary, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            child: Text(
              'Edit Profile',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCoachButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Message Coach',
          style: AppTextStyles.semiBold15(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildInformationButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton(
        onPressed: () =>
            Navigator.pushNamed(context, ProfileInfoView.routeName),
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

  Widget _buildAssignedPlanSection(BuildContext context) {
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
        _PlanCard(
          iconData: Icons.fitness_center,
          iconBgColor: AppColors.primaryBlue,
          title: 'Workout Upper',
          subtitle: 'Upper Body Strength',
        ),
        SizedBox(height: 10.h),
        _PlanCard(
          iconData: Icons.receipt_long,
          iconBgColor: AppColors.streakGreen,
          title: 'Diet Plan',
          subtitle: 'Muscle Gain Diet',
        ),
        SizedBox(height: 10.h),
        _PlanCard(
          iconData: Icons.emoji_events,
          iconBgColor: AppColors.streakFire,
          title: 'Fitness Goal',
          subtitle: 'Weight Loss',
        ),
      ],
    );
  }

  Widget _buildProgressOverviewSection(BuildContext context) {
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
        _TabSelector(
          tabs: _tabs,
          selectedIndex: _selectedTabIndex,
          onTabSelected: (i) => setState(() => _selectedTabIndex = i),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 200.h,
          child: _LineChart(dataPoints: _currentData, xLabels: _xLabels),
        ),
      ],
    );
  }

  Widget _buildSubscriptionInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subscription Information',
              style: AppTextStyles.semiBold15(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            Row(
              children: [
                Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: const BoxDecoration(
                    color: AppColors.streakGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  'Active',
                  style: AppTextStyles.medium14(context).copyWith(
                    color: AppColors.streakGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _SubscriptionRow(
          icon: Icons.access_time_rounded,
          label: 'Duration',
          value: '1 Month',
        ),
        SizedBox(height: 14.h),
        _SubscriptionRow(
          icon: Icons.calendar_month_outlined,
          label: 'Start date',
          value: '15 May 2026',
        ),
        SizedBox(height: 14.h),
        _SubscriptionRow(
          icon: Icons.calendar_month_outlined,
          label: 'End date',
          value: '15 Jun 2026',
          trailingHighlight: '(In 18 days)',
        ),
      ],
    );
  }
}

// ---------- Tab Selector ----------

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

// ---------- Plan Card ----------

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.semiBold14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: AppTextStyles.meduim12(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------- Subscription Row ----------

class _SubscriptionRow extends StatelessWidget {
  const _SubscriptionRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailingHighlight,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? trailingHighlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Text(
          label,
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        const Spacer(),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
              if (trailingHighlight != null)
                TextSpan(
                  text: ' $trailingHighlight',
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.streakFire),
                ),
            ],
          ),
        ),
      ],
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
