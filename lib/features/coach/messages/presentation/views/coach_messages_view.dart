import 'package:athletica/features/coach/messages/presentation/views/widgets/coach_messages_view_body.dart';
import 'package:flutter/material.dart';

class CoachMessagesView extends StatelessWidget {
  const CoachMessagesView({super.key});

  static const String routeName = 'coach-messages';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CoachMessagesViewBody());
  }
}
