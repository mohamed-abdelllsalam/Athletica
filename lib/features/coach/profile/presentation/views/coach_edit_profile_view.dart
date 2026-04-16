import 'package:athletica/features/coach/profile/presentation/views/widgets/coach_edit_profile_view_body.dart';
import 'package:flutter/material.dart';

class CoachEditProfileView extends StatelessWidget {
  const CoachEditProfileView({super.key});

  static const String routeName = 'coach-edit-profile';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CoachEditProfileViewBody());
  }
}
