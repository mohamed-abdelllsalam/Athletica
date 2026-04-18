import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';
import 'package:athletica/features/coach/messages/presentation/views/widgets/coach_contact_profile_view_body.dart';
import 'package:flutter/material.dart';

class CoachContactProfileView extends StatelessWidget {
  const CoachContactProfileView({super.key, required this.contact});

  static const String routeName = 'coach-contact-profile';

  final ChatContact contact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CoachContactProfileViewBody(contact: contact));
  }
}
