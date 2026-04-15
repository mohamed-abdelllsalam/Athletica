import 'package:athletica/features/complete_profile/presentation/views/widgets/complete_profile_view_body.dart';
import 'package:flutter/material.dart';

class CompleteProfileView extends StatelessWidget {
  const CompleteProfileView({super.key});
  static const String routeName = 'completeProfileView';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CompleteProfileViewBody(),
    );
  }
}
