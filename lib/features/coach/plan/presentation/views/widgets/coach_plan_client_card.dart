import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/coach_plan_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachPlanClientCard extends StatelessWidget {
  const CoachPlanClientCard({super.key, required this.client, this.onTap});

  final CoachPlanClient client;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Name — left column
            SizedBox(
              width: 110.w,
              child: Text(
                client.name,
                style: AppTextStyles.semiBold15(context).copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Macros — centre column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MacroLine(label: 'Fat', grams: client.fatGrams, context: context),
                  SizedBox(height: 4.h),
                  _MacroLine(label: 'Carp', grams: client.carbGrams, context: context),
                  SizedBox(height: 4.h),
                  _MacroLine(label: 'Protein', grams: client.proteinGrams, context: context),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Image — right column
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                width: 80.r,
                height: 80.r,
                color: AppColors.surfaceDark,
                child: client.imageAsset != null
                    ? Image.asset(client.imageAsset!, fit: BoxFit.cover)
                    : Icon(
                        Icons.person,
                        color: AppColors.textSecondary,
                        size: 34.sp,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroLine extends StatelessWidget {
  const _MacroLine({
    required this.label,
    required this.grams,
    required this.context,
  });

  final String label;
  final int grams;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Text(
      '$label:$grams g',
      style: AppTextStyles.meduim12(context).copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }
}
