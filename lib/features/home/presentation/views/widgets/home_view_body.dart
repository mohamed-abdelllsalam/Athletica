import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/home/presentation/views/widgets/home_app_bar.dart';
import 'package:athletica/features/home/presentation/views/widgets/meal_section.dart';
import 'package:athletica/features/home/presentation/views/widgets/notes_section.dart';
import 'package:athletica/features/home/presentation/views/widgets/nutrition_summary_card.dart';
import 'package:athletica/features/home/presentation/views/widgets/streak_section.dart';
import 'package:athletica/features/home/presentation/views/widgets/summary_section.dart';
import 'package:athletica/features/home/presentation/views/widgets/total_nutritions_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

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
              SizedBox(height: 28.h),
              const SummarySection(),
              SizedBox(height: 24.h),
              const NutritionSummaryCard(),
              SizedBox(height: 24.h),
              const TotalNutritionsBar(),
              SizedBox(height: 24.h),
              const MealSection(),
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
