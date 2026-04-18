import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/complete_profile/presentation/cubits/complete_profile_cubit.dart';
import 'package:athletica/features/complete_profile/presentation/views/widgets/complete_profile_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompleteProfileView extends StatelessWidget {
  const CompleteProfileView({super.key});
  static const String routeName = 'completeProfileView';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CompleteProfileCubit>(),
      child: const CompleteProfileViewBody(),
    );
  }
}
