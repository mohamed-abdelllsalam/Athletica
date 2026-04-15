import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/info/presentation/views/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoQuestionItem extends StatelessWidget {
  const InfoQuestionItem({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.extraBold14(
            context,
          ).copyWith(color: Colors.white),
        ),
        SizedBox(height: 6.h),
        const CustomTextField(),
      ],
    );
  }
}
