import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/info/domain/entities/client_question.dart';
import 'package:athletica/features/info/presentation/views/widgets/info_question_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoQuestionsPage extends StatelessWidget {
  const InfoQuestionsPage({
    super.key,
    required this.questions,
    required this.selections,
    required this.onSelected,
  });

  final List<ClientQuestion> questions;
  final Map<String, int> selections;
  final void Function(String questionId, int choiceIndex) onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          const _InfoPageHeader(),
          SizedBox(height: 16.h),
          for (int i = 0; i < questions.length; i++) ...[
            InfoQuestionItem(
              question: questions[i],
              selectedIndex: selections[questions[i].id],
              onSelected: (choiceIndex) =>
                  onSelected(questions[i].id, choiceIndex),
            ),
            if (i != questions.length - 1) SizedBox(height: 22.h),
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
          'Welcome Q&A',
          style: AppTextStyles.semiBold15(
            context,
          ).copyWith(color: Colors.white),
        ),
      ],
    );
  }
}
