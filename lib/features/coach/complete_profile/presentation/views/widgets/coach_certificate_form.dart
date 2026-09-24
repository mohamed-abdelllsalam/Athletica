import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'coach_dashed_upload_box.dart';

class CoachCertificateForm extends StatelessWidget {
  const CoachCertificateForm({
    super.key,
    required this.titleController,
    required this.onUpload,
    this.selectedFileName,
    this.selectedFileSize,
    this.titleError,
    this.fileError,
  });

  final TextEditingController titleController;
  final VoidCallback onUpload;
  final String? selectedFileName;
  final int? selectedFileSize;
  final String? titleError;
  final String? fileError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certificate',
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 6.h),
        Text(
          'Add a certificate to highlight your expertise to potential clients.',
          style: AppTextStyles.regular13(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 20.h),
        CoachDashedUploadBox(
          title: 'Upload your certificate',
          subtitle: 'Select a PDF certificate to upload.',
          onUploadTap: onUpload,
        ),
        SizedBox(height: 8.h),
        Text(
          'PDF only • Max 50 PDFs • Max 10 MB each',
          style: AppTextStyles.regular13(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        if (selectedFileName != null) ...[
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    selectedFileName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.medium14(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                ),
                if (selectedFileSize != null)
                  Text(
                    _formatBytes(selectedFileSize!),
                    style: AppTextStyles.meduim12(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
        if (fileError != null) ...[
          SizedBox(height: 8.h),
          Text(
            fileError!,
            style: AppTextStyles.regular13(
              context,
            ).copyWith(color: Colors.redAccent),
          ),
        ],
        SizedBox(height: 24.h),
        Text(
          'Certificate title',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 8.h),
        _InputField(
          controller: titleController,
          hint: 'Ex. Certified Strength Coach Level 2',
          errorText: titleError,
          maxLength: 200,
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kilobytes = bytes / 1024;
    if (kilobytes < 1024) return '${kilobytes.toStringAsFixed(1)} KB';
    return '${(kilobytes / 1024).toStringAsFixed(1)} MB';
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    this.errorText,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hint;
  final String? errorText;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      style: AppTextStyles.medium14(
        context,
      ).copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
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
