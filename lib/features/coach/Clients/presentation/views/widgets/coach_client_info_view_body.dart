import 'coach_legacy_assessment_item.dart';
import 'package:athletica/core/utils/app_colors.dart';
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
                  return CoachLegacyAssessmentItem(
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
