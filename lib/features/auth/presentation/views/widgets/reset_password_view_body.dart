import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/auth/presentation/views/otp_view.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResetPasswordViewBody extends StatelessWidget {
  const ResetPasswordViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    const String emailAddress = "mohamed.12@gmail.com";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reset your password', style: AppTextStyles.bold24(context)),
          const SizedBox(height: 12),
          Text(
            'please enter your email and we will send an OTP code in the next step to reset your password',
            style: AppTextStyles.medium13(context),
          ),
          const SizedBox(height: 29),
          Text(
            'Email Address',
            style: AppTextStyles.medium16(
              context,
            ).copyWith(color: const Color(0xFFEAFBF1).withValues()),
          ),
          const SizedBox(height: 15),
          TextFormField(
            autofillHints: const [AutofillHints.email],
            keyboardType: TextInputType.emailAddress,
            onFieldSubmitted: (value) {
              TextInput.finishAutofillContext();
            },
            initialValue: emailAddress,
            style: AppTextStyles.regular16(
              context,
            ).copyWith(color: Colors.white),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  width: 1,
                  color: const Color(0xCC206D3E),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              hintText: 'Enter your email',
              hintStyle: AppTextStyles.regular16(context).copyWith(),
            ),
          ),
          Spacer(),
          CustomButton(
            onPressed: () {
              Navigator.pushNamed(context, OtpView.routeName);
            },
            text: 'Continue',
          ),
          SizedBox(height: 7),
        ],
      ),
    );
  }
}
