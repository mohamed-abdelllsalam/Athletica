import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'coach_dashed_upload_box.dart';

class CoachCertificateForm extends StatelessWidget {
  const CoachCertificateForm({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.onUpload,
  });
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final VoidCallback onUpload;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certificates',
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 6.h),
        Text(
          'Add certificate details to highlight your expertise to potential clients',
          style: AppTextStyles.regular13(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 20.h),
        CoachDashedUploadBox(
          title: 'Upload your certificates',
          subtitle: 'Upload your certificates to verify your expertise.',
          onUploadTap: onUpload,
        ),
        SizedBox(height: 24.h),
        Text(
          'Certificate Name',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 8.h),
        _InputField(
          controller: nameController,
          hint: 'Ex. Certified Strength Coach Level 2',
        ),
        SizedBox(height: 20.h),
        Text(
          'Description',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 8.h),
        _InputField(
          controller: descriptionController,
          hint: 'Brief description or organization name',
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: AppTextStyles.medium14(
        context,
      ).copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.regular13(
          context,
        ).copyWith(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
