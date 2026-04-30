import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_info_cubit.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_state.dart';
import 'package:athletica/features/profile/presentation/views/widgets/profile_info_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileInfoView extends StatefulWidget {
  const ProfileInfoView({super.key});

  static const String routeName = 'profile-info';

  @override
  State<ProfileInfoView> createState() => _ProfileInfoViewState();
}

class _ProfileInfoViewState extends State<ProfileInfoView> {
  late final ProfileInfoCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ProfileInfoCubit>();
    final profileState = sl<ProfileCubit>().state;
    if (profileState is ProfileLoaded) {
      _cubit.loadAnswers(profileState.profile.clientId);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: const Scaffold(body: ProfileInfoViewBody()),
    );
  }
}
