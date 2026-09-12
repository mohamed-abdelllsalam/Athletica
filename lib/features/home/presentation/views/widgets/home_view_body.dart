import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/widgets/check_ins/check_in_ui.dart';
import 'package:athletica/features/check_ins/presentation/views/check_ins_preview_view.dart';
import 'package:athletica/features/home/presentation/views/widgets/home_app_bar.dart';
import 'package:athletica/features/home/presentation/views/widgets/notes_section.dart';
import 'package:athletica/features/home/presentation/views/widgets/nutritions_section.dart';
import 'package:athletica/features/home/presentation/views/widgets/streak_section.dart';
import 'package:athletica/features/home/presentation/views/widgets/summary_section.dart';
import 'package:athletica/features/home/presentation/views/widgets/workouts_section.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  int _selectedTab = 0;
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
              const HomeAppBar(),
              SizedBox(height: 24.h),
              const StreakSection(),
              if (kDebugMode) ...[
                SizedBox(height: 16.h),
                CheckInEntryCard(
                  onTap: () => Navigator.pushNamed(
                    context,
                    CheckInsPreviewView.routeName,
                    arguments: CheckInPreviewRole.client,
                  ),
                ),
              ],
              SizedBox(height: 28.h),
              SummarySection(
                selectedTab: _selectedTab,
                onTabChanged: (index) {
                  setState(() {
                    _selectedTab = index;
                  });
                },
              ),
              SizedBox(height: 24.h),
              _selectedTab == 0
                  ? const WorkoutsSection()
                  : const NutritionsSection(),
              SizedBox(height: 24.h),
              const NotesSection(),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
