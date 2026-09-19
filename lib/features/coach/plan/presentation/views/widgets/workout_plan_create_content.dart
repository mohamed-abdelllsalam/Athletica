import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachWorkoutPlanCreateContent extends StatelessWidget {
  const CoachWorkoutPlanCreateContent({
    super.key,
    required this.header,
    required this.overview,
    required this.note,
    required this.tabController,
    required this.onExit,
    required this.onSave,
  });
  final Widget header;
  final Widget overview;
  final Widget note;
  final TabController tabController;
  final VoidCallback onExit;
  final VoidCallback onSave;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: GestureDetector(
            onTap: onExit,
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.arrow_back_ios_new),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        header,
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Save Plan',
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: TabBar(
            controller: tabController,
            indicatorColor: AppColors.buttonColor,
            indicatorWeight: 2,
            labelStyle: AppTextStyles.semiBold14(context),
            unselectedLabelStyle: AppTextStyles.medium14(context),
            labelColor: AppColors.buttonColor,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Note'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [overview, note],
          ),
        ),
      ],
    );
  }
}
