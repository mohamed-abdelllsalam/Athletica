import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/info/domain/entities/info_question.dart';
import 'package:athletica/features/info/presentation/views/widgets/info_question_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoQuestionsPage extends StatelessWidget {
  const InfoQuestionsPage({
    super.key,
    required this.questions,
    required this.onBack,
  });

  final List<InfoQuestion> questions;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          IconButton(
            onPressed: onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 18.sp),
          ),
          SizedBox(height: 12.h),
          const _InfoPageHeader(),
          SizedBox(height: 16.h),
          for (int i = 0; i < questions.length; i++) ...[
            InfoQuestionItem(question: questions[i]),
            if (i != questions.length - 1) SizedBox(height: 14.h),
          ],
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}

class _InfoPageHeader extends StatelessWidget {
  const _InfoPageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            height: 87.h,
            width: 120.w,
            child: Image.asset('assets/images/logo.png'),
          ),
        ),
        SizedBox(height: 6.h),
        Center(
          child: Text(
            'Athletica',
            style: AppTextStyles.extraBold30(
              context,
            ).copyWith(color: const Color(0xff4C0DFD)),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Welcome Mohamed Q&A',
          style: AppTextStyles.semiBold15(context).copyWith(color: Colors.white),
        ),
      ],
    );
  }
}
