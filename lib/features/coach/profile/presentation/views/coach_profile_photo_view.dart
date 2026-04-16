import 'package:athletica/features/coach/profile/presentation/views/widgets/coach_profile_photo_view_body.dart';
import 'package:flutter/material.dart';

class CoachProfilePhotoView extends StatelessWidget {
  const CoachProfilePhotoView({super.key});

  static const String routeName = 'coach-profile-photo';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CoachProfilePhotoViewBody());
  }
}
