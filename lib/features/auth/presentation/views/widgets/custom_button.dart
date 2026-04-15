import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.onPressed, required this.text});
  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFF5273E0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyles.semiBold15(
            context,
          ).copyWith(color: const Color(0xffFFFFFF)),
        ),
      ),
    );
  }
}
