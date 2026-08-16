import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/auth/presentation/views/role_selection_view.dart';
import 'package:athletica/features/auth/presentation/views/sign_in_view.dart';
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
        Text(
          'Become the best\nversion of yourself',
          style: AppTextStyles.semiBold35(
            context,
          ).copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          'Start your journey and change your lives',
          style: AppTextStyles.regular16(
            context,
          ).copyWith(color: Color(0xFF919191)),
        ),
        const SizedBox(height: 96),
        CustomElveButton(
          onPressed: () {
            Navigator.pushNamed(context, RoleSelectionView.routeName);
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
              ).copyWith(color: Colors.white.withValues(alpha: 0.41)),
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
