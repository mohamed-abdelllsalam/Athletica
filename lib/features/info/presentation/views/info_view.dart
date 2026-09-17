import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_state.dart';
import 'package:athletica/features/auth/presentation/views/sign_in_view.dart';
import 'package:athletica/features/info/presentation/cubits/info_cubit.dart';
import 'package:athletica/features/info/presentation/views/widgets/info_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoView extends StatelessWidget {
  const InfoView({super.key});
  static const String routeName = 'info';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<InfoCubit>()),
        BlocProvider(create: (_) => sl<AuthCubit>()),
      ],
      child: const _InfoScaffold(),
    );
  }
}

class _InfoScaffold extends StatelessWidget {
  const _InfoScaffold();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthInitial) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    SignInView.routeName,
                    (_) => false,
                  );
                } else if (state is AuthFailureState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoggingOut = state is AuthLoading;
                return TextButton(
                  onPressed: isLoggingOut
                      ? null
                      : () => context.read<AuthCubit>().logout(),
                  child: isLoggingOut
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Logout'),
                );
              },
            ),
          ],
        ),
        body: const InfoViewBody(),
      ),
    );
  }
}
