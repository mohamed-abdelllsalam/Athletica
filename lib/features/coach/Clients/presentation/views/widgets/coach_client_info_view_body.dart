import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachClientInfoViewBody extends StatelessWidget {
  const CoachClientInfoViewBody({super.key, required this.client});

  final CoachClient client;

  @override
  Widget build(BuildContext context) {
    final questions = client.assessmentQuestions.isEmpty
        ? const [
            ClientHealthQuestion(
              question: 'No assessment details available yet.',
              answer: 'Waiting for client response',
            ),
          ]
        : client.assessmentQuestions;

    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                itemCount: questions.length,
                separatorBuilder: (_, _) => SizedBox(height: 20.h),
                itemBuilder: (context, index) {
                  final q = questions[index];
                  return _QuestionItem(
                    number: index + 1,
                    question: q.question,
                    answer: q.answer,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
        ),
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
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.primaryPurple),
        ),
        SizedBox(height: 8.h),
        Text(
          question,
          style: AppTextStyles.semiBold15(
            context,
          ).copyWith(color: AppColors.textPrimary, height: 1.25),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  answer,
                  style: AppTextStyles.semiBold14(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 26.r,
                height: 26.r,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(8.r),
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
