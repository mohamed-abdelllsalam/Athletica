import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/core/widgets/complete_profile_dialog.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_complete_profile_view.dart';
import 'package:athletica/features/coach/home/presentation/views/widgets/coach_home_view_body.dart';
import 'package:flutter/material.dart';

class CoachHomeView extends StatefulWidget {
  const CoachHomeView({super.key});

  static const String routeName = 'coach-home';

  @override
  State<CoachHomeView> createState() => _CoachHomeViewState();
}

class _CoachHomeViewState extends State<CoachHomeView> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_dialogShown) {
        _checkProfileAndShowDialog();
      }
    });
  }

  Future<void> _checkProfileAndShowDialog() async {
    // If the coach has ever tapped "Complete Profile" we never show the
    // dialog again — even after logout/login (persisted flag survives clearAll).
    final hasDismissed = await TokenStorageService.instance
        .hasDismissedCoachCompleteProfilePrompt();
    if (hasDismissed) return;

    final isComplete = await TokenStorageService.instance.isProfileComplete();
    if (isComplete || !mounted || _dialogShown) return;

    _dialogShown = true;
    final shouldComplete = await showCompleteProfileDialog(context);
    if (shouldComplete && mounted) {
      // Persist dismissal BEFORE navigating so rotation / re-login never
      // shows the dialog again, even if the user aborts the flow.
      await TokenStorageService.instance
          .setCoachCompleteProfilePromptDismissed();
      if (!mounted) return;
      await Navigator.pushNamed(context, CoachCompleteProfileView.routeName);
      if (mounted) _dialogShown = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const CoachHomeViewBody();
  }
}
