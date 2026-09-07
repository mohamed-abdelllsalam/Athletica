import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/home/presentation/views/widgets/home_view_body.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  static const String routeName = 'homeView';

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _checking = true;
  bool _profileComplete = false;

  @override
  void initState() {
    super.initState();
    sl<ProfileCubit>().loadProfile(forceRefresh: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkProfileCompletion();
    });
  }

  Future<void> _checkProfileCompletion() async {
    // Client onboarding gate disabled: go straight to home without the
    // "Complete Your Profile" dialog or forced questionnaire redirect.
    if (mounted) {
      setState(() {
        _checking = false;
        _profileComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ProfileCubit>(),
      child: Scaffold(
        body: _checking
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _profileComplete
                ? const HomeViewBody()
                : const SizedBox.shrink(),
      ),
    );
  }
}
