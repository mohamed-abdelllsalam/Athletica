import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:athletica/features/profile/presentation/views/widgets/profile_view_body.dart';
import 'package:athletica/features/streak/presentation/cubits/streak_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});
  static const String routeName = 'profileView';

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    sl<ProfileCubit>().loadProfile(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ProfileCubit>(),
      child: BlocProvider(
        create: (_) => sl<StreakCubit>(),
        child: const Scaffold(body: ProfileViewBody()),
      ),
    );
  }
}
