import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachNutritionPlanMetaForm extends StatelessWidget {
  const CoachNutritionPlanMetaForm({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.nameHasError,
    required this.descriptionHasError,
    required this.saving,
    required this.errorMessage,
    required this.bottomInset,
    required this.onSave,
    required this.onNameChanged,
    required this.onDescriptionChanged,
    required this.onDescriptionSubmitted,
  });
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final bool nameHasError;
  final bool descriptionHasError;
  final bool saving;
  final String? errorMessage;
  final double bottomInset;
  final VoidCallback onSave;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onDescriptionSubmitted;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Edit plan',
              style: AppTextStyles.semiBold14(
                context,
              ).copyWith(color: AppColors.textPrimary, fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Plan Name',
              style: AppTextStyles.meduim12(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(10.r),
                border: nameHasError
                    ? Border.all(color: Colors.redAccent)
                    : null,
              ),
              child: TextField(
                controller: nameController,
                autofocus: true,
                onChanged: onNameChanged,
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Plan name',
                  hintStyle: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Description',
              style: AppTextStyles.meduim12(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(10.r),
                border: descriptionHasError
                    ? Border.all(color: Colors.redAccent)
                    : null,
              ),
              child: TextField(
                controller: descriptionController,
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.done,
                onSubmitted: onDescriptionSubmitted,
                onChanged: onDescriptionChanged,
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Add a program description…',
                  hintStyle: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (errorMessage != null) ...[
              SizedBox(height: 8.h),
              Text(
                errorMessage!,
                style: AppTextStyles.meduim12(
                  context,
                ).copyWith(color: Colors.redAccent),
              ),
            ],
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: saving
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Save',
                        style: AppTextStyles.semiBold14(
                          context,
                        ).copyWith(color: Colors.white),
                      ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
