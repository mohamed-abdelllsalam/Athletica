import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileInfoViewBody extends StatelessWidget {
  const ProfileInfoViewBody({super.key});

  static const _questions = [
    (
      q: 'Have you had any past injuries?',
      a: 'Minor injuries (fully recovered)',
    ),
    (
      q: 'Has a doctor ever advised you not to exercise?',
      a: 'Yes (specific exercises only)',
    ),
    (q: 'Are you currently exercising?', a: '1–2 times/week'),
    (q: 'How many days per week do you train?', a: '5–6 days'),
    (q: 'What type of exercise do you do?', a: 'Gym / weight training'),
    (q: 'How would you rate your fitness level?', a: 'Average'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                itemCount: _questions.length,
                separatorBuilder: (_, _) => SizedBox(height: 24.h),
                itemBuilder: (context, index) {
                  final item = _questions[index];
                  return _QuestionItem(
                    number: index + 1,
                    question: item.q,
                    answer: item.a,
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
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.primaryBlue),
        ),
        SizedBox(height: 4.h),
        Text(
          question,
          style: AppTextStyles.semiBold15(
            context,
          ).copyWith(color: AppColors.textPrimary),
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
