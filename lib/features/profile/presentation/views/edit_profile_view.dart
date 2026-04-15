import 'package:athletica/features/profile/presentation/views/widgets/edit_profile_view_body.dart';
import 'package:flutter/material.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});
  static const String routeName = 'editProfileView';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: EditProfileViewBody());
  }
}
