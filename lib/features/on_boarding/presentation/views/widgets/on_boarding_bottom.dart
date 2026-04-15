import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/auth/presentation/views/sign_in_view.dart';
import 'package:athletica/features/auth/presentation/views/sign_up_view.dart';
import 'package:athletica/features/on_boarding/presentation/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class OnboardingBottom extends StatelessWidget {
  const OnboardingBottom({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Make Your Self\n',
                style: AppTextStyles.semiBold35(
                  context,
                ).copyWith(color: Colors.white),
              ),
              TextSpan(
                text: 'Better',
                style: AppTextStyles.regular35(
                  context,
                ).copyWith(color: const Color(0xFFBEF3D2)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Start now and live a healthy life',
          style: AppTextStyles.regular16(
            context,
          ).copyWith(color: Colors.white.withOpacity(0.8)),
        ),
        const SizedBox(height: 95),
        CustomElveButton(
          onPressed: () {
            Navigator.pushNamed(context, SignUpView.routeName);
          },
        ),
        const SizedBox(height: 42),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You already have an account?',
              style: AppTextStyles.medium15(
                context,
              ).copyWith(color: Colors.white.withOpacity(0.6)),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, SignInView.routeName);
              },
              child: Text(
                'Log In',
                style: AppTextStyles.medium16(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 64),
      ],
    );
  }
}
