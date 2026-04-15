import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/auth/presentation/views/new_password_view.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:athletica/features/auth/presentation/views/widgets/otp_field.dart';
import 'package:flutter/material.dart';

class OtpViewBody extends StatelessWidget {
  const OtpViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OTP code verification',
            style: AppTextStyles.bold24(context),
          ),
          const SizedBox(
            height: 12,
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'We have an OTP code to your email ',
                  style: AppTextStyles.medium13(context).copyWith(
                    color: const Color(0xFF909090),
                  ),
                ),
                TextSpan(
                  text: 'mohamed.12@gmail.com',
                  style: AppTextStyles.medium13(context).copyWith(
                    color: const Color(0xFFBEF3D2),
                  ),
                ),
                TextSpan(
                  text: ' Enter the OTP code bellow to verify',
                  style: AppTextStyles.medium13(context).copyWith(
                    color: const Color(0xFF909090),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 68,
          ),
          OtpField(),
          Spacer(),
          CustomButton(
            onPressed: () {
              Navigator.pushNamed(context, NewPasswordView.routeName);
            },
            text: 'Continue',
          ),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }
}
