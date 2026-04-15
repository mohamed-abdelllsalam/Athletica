import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomElveButton extends StatelessWidget {
  const CustomElveButton({super.key, required this.onPressed});
  final void Function() onPressed;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFD0E3FD),
              // foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.all(10),
            ),
            onPressed: onPressed,
            child: Text(
              'Get Start',
              style: AppTextStyles.medium16(
                context,
              ).copyWith(color: Color(0xFF22508C)),
            ),
          ),
        ),
      ],
    );
  }
}
