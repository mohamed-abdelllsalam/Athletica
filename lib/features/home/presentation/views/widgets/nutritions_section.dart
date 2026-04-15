import 'package:athletica/features/home/presentation/views/widgets/meal_section.dart';
import 'package:athletica/features/home/presentation/views/widgets/nutrition_summary_card.dart';
import 'package:athletica/features/home/presentation/views/widgets/total_nutritions_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionsSection extends StatelessWidget {
  const NutritionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NutritionSummaryCard(),
        SizedBox(height: 24.h),
        const TotalNutritionsBar(),
        SizedBox(height: 24.h),
        const MealSection(),
      ],
    );
  }
}
