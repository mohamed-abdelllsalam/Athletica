import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/splash/presentation/cubits/splash_cubit.dart';
import 'package:athletica/features/splash/presentation/views/widgets/splash_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});
  static const String routeName = 'splash';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SplashCubit>(),
      child: const SplashViewBody(),
    );
  }
}
