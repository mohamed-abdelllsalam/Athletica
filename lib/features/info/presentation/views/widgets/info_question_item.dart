import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/bilingual_text.dart';
import 'package:athletica/features/info/domain/entities/client_question.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Renders a single API-driven question according to its [QuestionType]:
/// choice questions render their available choices (storing indexes),
/// text questions render a normal text input (storing strings).
class InfoQuestionItem extends StatelessWidget {
  const InfoQuestionItem({
    super.key,
    required this.question,
    required this.answer,
    this.textController,
    required this.onSelected,
    required this.onTextChanged,
  });

  final ClientQuestion question;

  /// Current answer: int choice index for choice questions,
  /// String for text questions.
  final Object? answer;
  final TextEditingController? textController;
  final ValueChanged<int> onSelected;
  final ValueChanged<String> onTextChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.questionEn != null && question.questionAr != null)
          BilingualText(
            english: question.questionEn!,
            arabic: question.questionAr!,
            style: AppTextStyles.extraBold14(
              context,
            ).copyWith(color: Colors.white),
          )
        else
          Text(
            question.question,
            style: AppTextStyles.extraBold14(
              context,
            ).copyWith(color: Colors.white),
          ),
        SizedBox(height: 10.h),
        if (question.isTextQuestion)
          _buildTextInput(context)
        else
          ..._buildChoices(),
      ],
    );
  }

  List<Widget> _buildChoices() {
    return [
      for (int i = 0; i < question.choices.length; i++) ...[
        _ChoiceTile(
          label: question.choices[i],
          labelEn: question.choicesEn != null && i < question.choicesEn!.length
              ? question.choicesEn![i]
              : null,
          labelAr: question.choicesAr != null && i < question.choicesAr!.length
              ? question.choicesAr![i]
              : null,
          isSelected: answer == i,
          onTap: () => onSelected(i),
        ),
        if (i != question.choices.length - 1) SizedBox(height: 8.h),
      ],
    ];
  }

  Widget _buildTextInput(BuildContext context) {
    return TextField(
      controller: textController,
      onChanged: onTextChanged,
      maxLines: null,
      style: AppTextStyles.medium14(context).copyWith(color: Colors.white),
      cursorColor: AppColors.primaryPurple,
      decoration: InputDecoration(
        hintText: 'Type your answer',
        hintStyle: AppTextStyles.medium14(
          context,
        ).copyWith(color: Colors.white.withValues(alpha: 0.4)),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        enabledBorder: _border(const Color(0xFF3A3A3A)),
        focusedBorder: _border(AppColors.primaryPurple),
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.r),
    borderSide: BorderSide(width: 1.2, color: color),
  );
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    this.labelEn,
    this.labelAr,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String? labelEn;
  final String? labelAr;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            width: 1.2,
            color: isSelected
                ? AppColors.primaryPurple
                : const Color(0xFF3A3A3A),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20.r,
              height: 20.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: isSelected
                      ? AppColors.primaryPurple
                      : const Color(0xFF8A8A8A),
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.r,
                        height: 10.r,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryPurple,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: labelEn != null && labelAr != null
                  ? BilingualText(
                      english: labelEn!,
                      arabic: labelAr!,
                      style: AppTextStyles.medium14(
                        context,
                      ).copyWith(color: Colors.white),
                    )
                  : Text(
                      label,
                      style: AppTextStyles.medium14(
                        context,
                      ).copyWith(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
