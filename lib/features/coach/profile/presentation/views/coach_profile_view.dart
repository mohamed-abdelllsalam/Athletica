import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:athletica/features/coach/profile/presentation/views/widgets/coach_profile_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachProfileView extends StatelessWidget {
  const CoachProfileView({super.key});

  static const String routeName = 'coach-profile';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: const CoachProfileViewBody(),
    );
  }
}