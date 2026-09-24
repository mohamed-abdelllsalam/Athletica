import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/usecases/check_client_profile_completion_usecase.dart';
import 'package:athletica/features/home/presentation/views/widgets/home_view_body.dart';
import 'package:athletica/features/info/presentation/views/info_view.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:athletica/features/streak/presentation/cubits/streak_cubit.dart';
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

  /// Defensive questionnaire gate: Home must not render until backend totals
  /// confirm completion. Fail-closed — incomplete or error routes to Info.
  Future<void> _checkProfileCompletion() async {
    final result = await sl<CheckClientProfileCompletionUseCase>()();
    if (!mounted) return;
    final complete = switch (result) {
      ApiSuccess(:final data) => data,
      ApiError() => false,
    };
    if (!mounted) return;
    if (complete) {
      setState(() {
        _checking = false;
        _profileComplete = true;
      });
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        InfoView.routeName,
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ProfileCubit>(),
      child: BlocProvider(
        create: (_) => sl<StreakCubit>(),
        child: Scaffold(
          body: _checking
              ? const Center(child: CircularProgressIndicator())
              : _profileComplete
                  ? const HomeViewBody()
                  : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
