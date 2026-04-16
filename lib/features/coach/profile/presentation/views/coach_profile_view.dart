import 'package:athletica/features/coach/profile/presentation/views/widgets/coach_profile_view_body.dart';
import 'package:flutter/material.dart';

class CoachProfileView extends StatelessWidget {
  const CoachProfileView({super.key});

  static const String routeName = 'coach-profile';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CoachProfileViewBody());
  }
}
