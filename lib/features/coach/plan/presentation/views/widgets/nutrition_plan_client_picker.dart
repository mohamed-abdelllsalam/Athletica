import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/assigned_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachNutritionPlanClientPicker extends StatelessWidget {
  const CoachNutritionPlanClientPicker({
    super.key,
    required this.searchController,
    required this.selectedClientId,
    required this.filtered,
    required this.isAssigning,
    required this.onSearchChanged,
    required this.onClientSelected,
    required this.onSubmit,
  });
  final TextEditingController searchController;
  final String? selectedClientId;
  final List<AssignedClient> filtered;
  final bool isAssigning;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onClientSelected;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 20.sp,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 80.h,
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'No assigned clients found',
                    style: AppTextStyles.meduim12(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => SizedBox(width: 16.w),
                  itemBuilder: (context, index) {
                    final client = filtered[index];
                    final isSelected = selectedClientId == client.relationId;
                    final name = client.name;
                    return GestureDetector(
                      onTap: () => onClientSelected(client.relationId),
                      child: Column(
                        children: [
                          Container(
                            width: 48.r,
                            height: 48.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceDark,
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.primaryBlue,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                              size: 26.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          SizedBox(
                            width: 56.w,
                            child: Text(
                              name.split(' ').first,
                              style: AppTextStyles.meduim11(
                                context,
                              ).copyWith(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: isAssigning ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: isAssigning
                ? SizedBox(
                    height: 22.h,
                    width: 22.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Submit',
                    style: AppTextStyles.medium14(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}
