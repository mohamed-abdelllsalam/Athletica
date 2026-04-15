import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Color(0xffdddfdf),
            thickness: 1,
          ),
        ),
        const SizedBox(
          width: 18,
        ),
        CircleAvatar(
          backgroundColor: Color(0xFF141414),
          radius: 10,
          child: Text(
            textAlign: TextAlign.center,
            'Or',
            style: AppTextStyles.meduim11(context).copyWith(
              color: Color(0xFF1A8142),
            ),
          ),
        ),
        const SizedBox(
          width: 16,
        ),
        const Expanded(
          child: Divider(
            color: Color(0xffdddfdf),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
