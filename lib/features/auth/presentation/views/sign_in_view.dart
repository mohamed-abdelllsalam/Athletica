import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:athletica/features/auth/presentation/views/widgets/sign_in_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key, this.sessionExpired = false});
  static const String routeName = 'signInView';

  /// When true, the login page shows a one-time "session expired" message.
  /// Set by [ApiClient] after a 401 / "Authentication required" response.
  final bool sessionExpired;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: Scaffold(body: SignInViewBody(sessionExpired: sessionExpired)),
    );
  }
}
