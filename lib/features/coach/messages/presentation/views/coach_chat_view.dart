import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';
import 'package:athletica/features/coach/messages/presentation/views/widgets/coach_chat_view_body.dart';
import 'package:flutter/material.dart';

class CoachChatView extends StatelessWidget {
  const CoachChatView({super.key, required this.contact});

  static const String routeName = 'coach-chat';

  final ChatContact contact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CoachChatViewBody(contact: contact));
  }
}
