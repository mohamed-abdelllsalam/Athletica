import 'package:athletica/features/notifications/presentation/push_coordinator.dart';
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
  bool _profileCheckFailed = false;

  @override
  void initState() {
    super.initState();
    sl<ProfileCubit>().loadProfile(forceRefresh: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkProfileCompletion();
    });
  }

  /// Defensive questionnaire gate: Home must not render until backend totals
  /// confirm completion. A failed request must not imply an incomplete profile.
  Future<void> _checkProfileCompletion() async {
    if (_profileCheckFailed) {
      setState(() {
        _checking = true;
        _profileCheckFailed = false;
      });
    }
    final result = await sl<CheckClientProfileCompletionUseCase>()();
    if (!mounted) return;
    if (result is ApiError<bool>) {
      setState(() {
        _checking = false;
        _profileCheckFailed = true;
      });
      return;
    }
    final complete = (result as ApiSuccess<bool>).data;
    if (complete) {
      if (sl.isRegistered<PushCoordinator>()) {
        sl<PushCoordinator>().navigatorReady(true);
      }
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
              : _profileCheckFailed
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Could not verify your profile. Please try again.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _checkProfileCompletion,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : _profileComplete
              ? const HomeViewBody()
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
