import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_info_cubit.dart';
import 'package:athletica/features/profile/presentation/views/widgets/profile_info_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileInfoView extends StatelessWidget {
  const ProfileInfoView({super.key, required this.clientId});

  static const String routeName = 'profile-info';
  final String clientId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileInfoCubit>()..loadAnswers(clientId),
      child: const Scaffold(body: ProfileInfoViewBody()),
    );
  }
}
