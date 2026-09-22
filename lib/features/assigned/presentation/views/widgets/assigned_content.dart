import 'package:athletica/features/assigned/domain/entities/client_assigned.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/nutrition_section.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/workout_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AssignedContent extends StatelessWidget {
  const AssignedContent({super.key, required this.assigned});

  final ClientAssigned assigned;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          WorkoutSection(workout: assigned.workout),
          SizedBox(height: 24.h),
          NutritionSection(nutrition: assigned.nutrition),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}
