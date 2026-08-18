import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.text, this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isEnabled
              ? AppColors.buttonColor
              : const Color(0xFF3E3E4E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyles.semiBold15(context).copyWith(
            color: isEnabled
                ? const Color(0xffFFFFFF)
                : const Color(0xFFB2B2B2),
          ),
        ),
      ),
    );
  }
}
