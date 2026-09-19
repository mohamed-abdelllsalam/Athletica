import 'widgets/coach_client_info_header.dart';
import 'widgets/coach_client_assessment_item.dart';
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
                  CoachClientInfoHeader(client: client),
                  SizedBox(height: 24.h),
                  if (questions.isNotEmpty) ...[
                    Text(
                      'Assessment Questions',
                      style: AppTextStyles.bold20(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 16.h),
                    ...List.generate(questions.length, (index) {
                      final qa = questions[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: CoachClientAssessmentItem(
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
                          style: AppTextStyles.medium14(
                            context,
                          ).copyWith(color: AppColors.textSecondary),
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
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
