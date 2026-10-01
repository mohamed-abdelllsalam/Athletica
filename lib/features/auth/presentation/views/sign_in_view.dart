import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:athletica/features/auth/presentation/views/widgets/sign_in_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInView extends StatelessWidget {
  const SignInView({
    super.key,
    this.sessionExpired = false,
    this.completeProfileAfterLogin = false,
  });
  static const String routeName = 'signInView';

  /// When true, the login page shows a one-time "session expired" message.
  /// Set by [ApiClient] after a 401 / "Authentication required" response.
  final bool sessionExpired;

  /// True only on the sign-in page reached right after a coach's email
  /// verification during signup — such coaches go to Complete Profile
  /// after logging in instead of Coach Home. Transient: never persisted.
  final bool completeProfileAfterLogin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: Scaffold(
        body: SignInViewBody(
          sessionExpired: sessionExpired,
          completeProfileAfterLogin: completeProfileAfterLogin,
        ),
      ),
    );
  }
}
