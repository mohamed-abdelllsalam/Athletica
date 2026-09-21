import 'package:athletica/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionCard extends StatelessWidget {
  const NutritionCard({super.key, required this.child, this.outlined = false});
  final Widget child;
  final bool outlined;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.r),
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      border: outlined
          ? Border.all(color: AppColors.primaryPurple.withValues(alpha: .25))
          : null,
    ),
    child: child,
  );
}
