import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:athletica/features/auth/presentation/views/widgets/sign_up_email_verification_otp_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpEmailVerificationOtpView extends StatelessWidget {
  const SignUpEmailVerificationOtpView({
    super.key,
    this.email = '',
    this.isNewCoach = false,
  });

  final String email;

  /// True when the OTP screen was reached through the coach signup flow.
  /// Such coaches are routed to Complete Profile after their first login.
  final bool isNewCoach;

  static const String routeName = 'signUpEmailVerificationOtpView';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
        ),
        body: SignUpEmailVerificationOtpViewBody(
          email: email,
          isNewCoach: isNewCoach,
        ),
      ),
    );
  }
}
