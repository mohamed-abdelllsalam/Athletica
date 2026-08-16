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
  late final ProfileInfoCubit _infoCubit;
  late final ProfileCubit _profileCubit;
  bool _requestedLoad = false;

  @override
  void initState() {
    super.initState();
    _infoCubit = sl<ProfileInfoCubit>();
    _profileCubit = sl<ProfileCubit>();
    _maybeLoadAnswers(_profileCubit.state);
  }

  void _maybeLoadAnswers(ProfileState state) {
    if (_requestedLoad) return;
    if (state is ProfileLoaded) {
      _requestedLoad = true;
      _infoCubit.loadAnswers(state.profile.clientId);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _profileCubit),
        BlocProvider.value(value: _infoCubit),
      ],
      child: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) => _maybeLoadAnswers(state),
        child: const Scaffold(body: ProfileInfoViewBody()),
      ),
    );
  }
}
