import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachSpecializationField extends StatelessWidget {
  const CoachSpecializationField({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Specialization? selected;
  final ValueChanged<Specialization?> onChanged;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specialization',
          style: AppTextStyles.medium13(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<Specialization>(
          initialValue: selected,
          isExpanded: true,
          dropdownColor: AppColors.cardBackground,
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: false,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.textTertiary, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
          items: Specialization.values.map((specialization) {
            return DropdownMenuItem(
              value: specialization,
              child: Text(specialization.label(locale)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class CoachLocationField extends StatelessWidget {
  const CoachLocationField({
    super.key,
    required this.selected,
    required this.items,
    required this.onClear,
    required this.onChanged,
  });

  final String? selected;
  final List<String> items;
  final VoidCallback onClear;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Location',
              style: AppTextStyles.medium13(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            if (selected != null)
              GestureDetector(
                onTap: onClear,
                child: Text(
                  'Clear',
                  style: AppTextStyles.medium13(
                    context,
                  ).copyWith(color: AppColors.primaryBlue),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          initialValue: selected,
          isExpanded: true,
          dropdownColor: AppColors.cardBackground,
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Select your Location',
            hintStyle: AppTextStyles.medium13(
              context,
            ).copyWith(color: AppColors.textSecondary),
            filled: false,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.textTertiary, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
          items: items.map((location) {
            return DropdownMenuItem(
              value: location,
              child: Text(location, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class CoachProfileTextField extends StatelessWidget {
  const CoachProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTextStyles.medium14(
        context,
      ).copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.medium13(
          context,
        ).copyWith(color: AppColors.textSecondary),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: AppTextStyles.medium13(
          context,
        ).copyWith(color: AppColors.primaryBlue),
        filled: false,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.textTertiary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );
  }
}
