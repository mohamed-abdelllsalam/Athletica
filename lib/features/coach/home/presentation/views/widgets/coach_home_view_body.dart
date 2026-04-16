import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/home/presentation/views/widgets/coach_bottom_nav_bar.dart';
import 'package:athletica/features/coach/profile/presentation/views/coach_profile_view.dart';
import 'package:athletica/features/coach/home/presentation/views/widgets/coach_home_app_bar.dart';
import 'package:athletica/features/coach/home/presentation/views/widgets/coach_insights_section.dart';
import 'package:athletica/features/coach/home/presentation/views/widgets/coach_stats_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachHomeViewBody extends StatefulWidget {
  const CoachHomeViewBody({super.key});

  @override
  State<CoachHomeViewBody> createState() => _CoachHomeViewBodyState();
}

class _CoachHomeViewBodyState extends State<CoachHomeViewBody> {
  // Local UI state — no business logic
  int _selectedPeriod = 0; // 0 = Daily, 1 = Monthly
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              const CoachHomeAppBar(),
              SizedBox(height: 20.h),
              const CoachStatsGrid(),
              SizedBox(height: 28.h),
              CoachInsightsSection(
                selectedPeriod: _selectedPeriod,
                onPeriodChanged: (index) {
                  setState(() => _selectedPeriod = index);
                },
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CoachBottomNavBar(
        selectedIndex: _selectedNavIndex,
        onTap: (index) {
          if (index == 3) {
            Navigator.pushNamed(context, CoachProfileView.routeName);
          } else {
            setState(() => _selectedNavIndex = index);
          }
        },
      ),
    );
  }
}
