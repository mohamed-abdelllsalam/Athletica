import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/verification_utils.dart';
import 'package:athletica/features/auth/presentation/views/sign_up_email_verification_otp_view.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class VerifyYourIdentityViewBody extends StatelessWidget {
  const VerifyYourIdentityViewBody({super.key, required this.email});

  final String email;

  String get maskedEmail => maskEmail(email);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Verify your identity',
              style: AppTextStyles.bold24(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            Text(
              'To continue, we need to verify your identity.\nChoose how you’d like to receive a verification code.',
              style: AppTextStyles.medium16(
                context,
              ).copyWith(color: const Color(0xFF9E9E9E), height: 1.45),
            ),
            const SizedBox(height: 26),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2E2E2E), width: 1.2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: AppTextStyles.medium16(
                            context,
                          ).copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          maskedEmail,
                          style: AppTextStyles.regular16(
                            context,
                          ).copyWith(color: const Color(0xFFA9A9A9)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFB9B9B9),
                        width: 2,
                      ),
                      color: Colors.transparent,
                    ),
                    child: const Center(
                      child: CircleAvatar(
                        radius: 6,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            CustomButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  SignUpEmailVerificationOtpView.routeName,
                  arguments: email,
                );
              },
              text: 'Continue',
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
