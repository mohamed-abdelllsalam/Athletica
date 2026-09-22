import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/assigned/domain/entities/client_assigned.dart';
import 'package:athletica/features/assigned/presentation/cubits/assigned_cubit.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/assign_template_sheet.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/assigned_nutrition_card.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/empty_state_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionSection extends StatelessWidget {
  const NutritionSection({super.key, required this.nutrition});

  final AssignedNutrition? nutrition;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.receipt_long,
                color: AppColors.streakGreen, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Nutrition',
              style: AppTextStyles.bold20(context)
                  .copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (nutrition != null)
          AssignedNutritionCard(nutrition: nutrition!)
        else
          EmptyStateCard(
            icon: Icons.receipt_long,
            label: 'No nutrition plan assigned',
            buttonLabel: 'Assign Nutrition',
            onPressed: () => _openNutritionSheet(context),
          ),
      ],
    );
  }

  void _openNutritionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AssignedCubit>(),
        child: const AssignTemplateSheet(type: AssignType.nutrition),
      ),
    );
  }
}
