import 'coach_contact_profile_card.dart';
import 'coach_contact_goals_section.dart';
import 'coach_contact_lifestyle_section.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachContactProfileViewBody extends StatelessWidget {
  const CoachContactProfileViewBody({super.key, required this.contact});

  final ChatContact contact;

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
                    CoachContactProfileCard(contact: contact),
                    SizedBox(height: 24.h),
                    if (contact.goals.isNotEmpty) ...[
                      CoachContactGoalsSection(contact: contact),
                      SizedBox(height: 24.h),
                    ],
                    if (_hasLifestyle) ...[
                      CoachContactLifestyleSection(contact: contact),
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
            child: Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            contact.name,
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
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
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
