import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/info/domain/entities/info_question.dart';
import 'package:athletica/features/info/presentation/views/widgets/info_question_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoQuestionsPage extends StatefulWidget {
  const InfoQuestionsPage({
    super.key,
    required this.questions,
    required this.onBack,
  });

  final List<InfoQuestion> questions;
  final VoidCallback onBack;

  @override
  InfoQuestionsPageState createState() => InfoQuestionsPageState();
}

class InfoQuestionsPageState extends State<InfoQuestionsPage> {
  late final Map<String, String?> _answers;

  @override
  void initState() {
    super.initState();
    _answers = {for (final q in widget.questions) q.key: null};
  }

  bool get allAnswered =>
      _answers.values.every((v) => v != null && v.trim().isNotEmpty);

  Map<String, String> get answers =>
      Map.fromEntries(_answers.entries.where((e) => e.value != null).map((e) => MapEntry(e.key, e.value!)));

  void _onQuestionChanged(String key, String? value) {
    setState(() => _answers[key] = value?.trim().isEmpty == true ? null : value);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          IconButton(
            onPressed: widget.onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 18.sp),
          ),
          SizedBox(height: 12.h),
          const _InfoPageHeader(),
          SizedBox(height: 16.h),
          for (int i = 0; i < widget.questions.length; i++) ...[
            InfoQuestionItem(
              question: widget.questions[i],
              onChanged: (value) => _onQuestionChanged(widget.questions[i].key, value),
            ),
            if (i != widget.questions.length - 1) SizedBox(height: 14.h),
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
          style:
              AppTextStyles.semiBold15(context).copyWith(color: Colors.white),
        ),
      ],
    );
  }
}
