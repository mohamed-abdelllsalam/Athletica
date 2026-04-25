import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachContactProfileViewBody extends StatelessWidget {
  const CoachContactProfileViewBody({super.key, required this.contact});

  final ChatContact contact;

  static IconData _goalIcon(String goal) {
    if (goal.toLowerCase().contains('weight')) {
      return Icons.monitor_weight_outlined;
    } else if (goal.toLowerCase().contains('muscle')) {
      return Icons.fitness_center;
    } else if (goal.toLowerCase().contains('energy')) {
      return Icons.bolt;
    }
    return Icons.calendar_today_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    _buildProfileCard(context),
                    SizedBox(height: 24.h),
                    if (contact.goals.isNotEmpty) ...[
                      _buildGoalsSection(context),
                      SizedBox(height: 24.h),
                    ],
                    if (_hasLifestyle) ...[
                      _buildLifestyleSection(context),
                      SizedBox(height: 32.h),
                    ],
                  ],
                ),
              ),
            ),
            _buildMessageButton(context),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  bool get _hasLifestyle =>
      contact.experience != null ||
      contact.schedule != null ||
      contact.nutrition != null;

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back,
                color: AppColors.textPrimary, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Text(
            contact.name,
            style: AppTextStyles.semiBold15(context)
                .copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50.r),
          child: Container(
            width: 90.r,
            height: 90.r,
            color: AppColors.surfaceDark,
            child: contact.imageAsset != null
                ? Image.asset(contact.imageAsset!, fit: BoxFit.cover)
                : Icon(Icons.person,
                    color: AppColors.textSecondary, size: 40.sp),
          ),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.name,
              style: AppTextStyles.bold20(context)
                  .copyWith(color: AppColors.textPrimary),
            ),
            if (contact.heightCm != null || contact.weightKg != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  if (contact.heightCm != null)
                    _StatItem(
                      label: 'Height',
                      value: '${contact.heightCm} Cm',
                      context: context,
                    ),
                  if (contact.heightCm != null && contact.weightKg != null)
                    SizedBox(width: 24.w),
                  if (contact.weightKg != null)
                    _StatItem(
                      label: 'Weight',
                      value: '${contact.weightKg} Kg',
                      context: context,
                    ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildGoalsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goals',
          style: AppTextStyles.bold20(context)
              .copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 14.h),
        ...contact.goals.map(
          (goal) => Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: Row(
              children: [
                Icon(_goalIcon(goal),
                    color: AppColors.textPrimary, size: 22.sp),
                SizedBox(width: 12.w),
                Text(
                  goal,
                  style: AppTextStyles.medium15(context)
                      .copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLifestyleSection(BuildContext context) {
    final items = <({String label, String value})>[
      if (contact.experience != null)
        (label: 'Experience', value: contact.experience!),
      if (contact.schedule != null)
        (label: 'Schedule', value: contact.schedule!),
      if (contact.nutrition != null)
        (label: 'Nutrition', value: contact.nutrition!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Life Style',
          style: AppTextStyles.bold20(context)
              .copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 4.h),
        ...items.map(
          (item) => Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90.w,
                      child: Text(
                        item.label,
                        style: AppTextStyles.semiBold14(context)
                            .copyWith(color: AppColors.primaryBlue),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.value,
                        style: AppTextStyles.medium14(context)
                            .copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                  color: AppColors.surfaceDark, height: 1, thickness: 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
            elevation: 0,
          ),
          child: Text(
            'Message ${contact.name.split(' ').first}',
            style: AppTextStyles.semiBold15(context)
                .copyWith(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.context,
  });

  final String label;
  final String value;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.meduim12(context)
              .copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTextStyles.medium14(context)
              .copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
