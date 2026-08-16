import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/info/domain/entities/info_question.dart';
import 'package:athletica/features/info/presentation/views/widgets/custom_dropdown_field.dart';
import 'package:athletica/features/info/presentation/views/widgets/custom_multiselect_field.dart';
import 'package:athletica/features/info/presentation/views/widgets/custom_text_field.dart';
import 'package:athletica/features/info/presentation/views/widgets/custom_textarea_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoQuestionItem extends StatelessWidget {
  const InfoQuestionItem({
    super.key,
    required this.question,
    required this.onChanged,
  });

  final InfoQuestion question;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.prompt,
          style:
              AppTextStyles.extraBold14(context).copyWith(color: Colors.white),
        ),
        SizedBox(height: 6.h),
        switch (question.type) {
          InfoQuestionType.number => CustomTextField(
              keyboardType: TextInputType.number,
              onChanged: onChanged,
            ),
          InfoQuestionType.textarea => CustomTextareaField(
              onChanged: (v) => onChanged(v),
            ),
          InfoQuestionType.multiselect => CustomMultiselectField(
              options: question.options!,
              onChanged: onChanged,
            ),
          InfoQuestionType.select => CustomDropdownField(
              options: question.options!,
              onChanged: onChanged,
            ),
        },
      ],
    );
  }
}
