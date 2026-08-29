import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/client_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachClientInfoView extends StatelessWidget {
  const CoachClientInfoView({super.key, required this.detail});

  static const String routeName = 'coach-client-info';

  final ClientDetail detail;

  @override
  Widget build(BuildContext context) {
    final client = detail.client;
    final questions = detail.questionsAnswers;

    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                children: [
                  _buildClientHeader(context, client),
                  SizedBox(height: 24.h),
                  if (questions.isNotEmpty) ...[
                    Text(
                      'Assessment Questions',
                      style: AppTextStyles.bold20(context).copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ...List.generate(questions.length, (index) {
                      final qa = questions[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: _QuestionItem(
                          number: index + 1,
                          question: qa.question,
                          answer: qa.answerText ?? qa.answer,
                        ),
                      );
                    }),
                  ] else ...[
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40.h),
                        child: Text(
                          'No assessment answers yet',
                          style: AppTextStyles.medium14(context).copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'Client Information',
            style: AppTextStyles.semiBold15(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientHeader(BuildContext context, ClientProfile client) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40.r),
                child: Container(
                  width: 60.r,
                  height: 60.r,
                  color: AppColors.surfaceDark,
                  child: client.profileImage != null
                      ? Image.network(client.profileImage!, fit: BoxFit.cover)
                      : Icon(
                          Icons.person,
                          color: AppColors.textSecondary,
                          size: 28.sp,
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.displayName,
                      style: AppTextStyles.semiBold15(context).copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      client.email,
                      style: AppTextStyles.meduim12(context).copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            children: [
              if (client.gender != null)
                _InfoChip(label: 'Gender', value: client.gender!),
              if (client.goal != null)
                _InfoChip(label: 'Goal', value: client.goal!),
              if (client.heightCm != null)
                _InfoChip(
                    label: 'Height', value: '${client.heightCm} cm'),
              if (client.weightKg != null)
                _InfoChip(
                    label: 'Weight', value: '${client.weightKg} kg'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.meduim12(context).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.meduim12(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionItem extends StatelessWidget {
  const _QuestionItem({
    required this.number,
    required this.question,
    required this.answer,
  });

  final int number;
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Q$number',
          style: AppTextStyles.semiBold14(context).copyWith(
            color: AppColors.primaryBlue,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          question,
          style: AppTextStyles.semiBold15(context).copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  answer,
                  style: AppTextStyles.semiBold14(context).copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 26.r,
                height: 26.r,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  Icons.check,
                  color: AppColors.textPrimary,
                  size: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
