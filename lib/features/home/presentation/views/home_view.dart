import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/widgets/complete_profile_dialog.dart';
import 'package:athletica/features/auth/domain/usecases/check_client_profile_completion_usecase.dart';
import 'package:athletica/features/home/presentation/views/widgets/home_view_body.dart';
import 'package:athletica/features/info/presentation/views/info_view.dart';
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
    final isComplete = await TokenStorageService.instance.isProfileComplete();
    if (isComplete) {
      if (mounted) setState(() { _checking = false; _profileComplete = true; });
      return;
    }

    final useCase = sl<CheckClientProfileCompletionUseCase>();
    final result = await useCase();
    if (!mounted) return;

    switch (result) {
      case ApiSuccess(:final data):
        if (data) {
          await TokenStorageService.instance.saveProfileComplete();
          if (mounted) setState(() { _checking = false; _profileComplete = true; });
        } else {
          if (mounted) setState(() { _checking = false; _profileComplete = false; });
          final shouldComplete = await showCompleteProfileDialog(context);
          if (shouldComplete && mounted) {
            Navigator.pushReplacementNamed(context, InfoView.routeName);
          }
        }
      case ApiError():
        if (mounted) setState(() { _checking = false; _profileComplete = true; });
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
