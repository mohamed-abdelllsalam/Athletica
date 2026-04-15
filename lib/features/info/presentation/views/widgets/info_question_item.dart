import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/info/domain/entities/info_question.dart';
import 'package:athletica/features/info/presentation/views/widgets/custom_dropdown_field.dart';
import 'package:athletica/features/info/presentation/views/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoQuestionItem extends StatelessWidget {
  const InfoQuestionItem({super.key, required this.question});

  final InfoQuestion question;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.question,
          style: AppTextStyles.extraBold14(context).copyWith(color: Colors.white),
        ),
        SizedBox(height: 6.h),
        if (question.type == InfoQuestionType.text)
          const CustomTextField(keyboardType: TextInputType.number)
        else
          CustomDropdownField(options: question.options!),
      ],
    );
  }
}
