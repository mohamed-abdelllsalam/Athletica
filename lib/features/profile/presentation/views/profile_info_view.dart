import 'package:athletica/features/profile/presentation/views/widgets/profile_info_view_body.dart';
import 'package:flutter/material.dart';

class ProfileInfoView extends StatelessWidget {
  const ProfileInfoView({super.key});

  static const String routeName = 'profile-info';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: ProfileInfoViewBody());
  }
}
