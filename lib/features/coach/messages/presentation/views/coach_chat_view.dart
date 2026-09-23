import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:athletica/features/chat/presentation/models/chat_route_args.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';
import 'package:athletica/features/coach/messages/presentation/models/coach_chat_route_args.dart';
import 'package:athletica/features/coach/messages/presentation/views/widgets/coach_chat_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachChatView extends StatelessWidget {
  const CoachChatView({super.key, required this.contact, this.chatArgs});

  static const String routeName = 'coach-chat';

  final ChatContact contact;
  final CoachChatRouteArgs? chatArgs;

  @override
  Widget build(BuildContext context) {
    final args = chatArgs;
    if (args == null) {
      return Scaffold(body: CoachChatViewBody(contact: contact));
    }
    return BlocProvider(
      create: (_) => sl<ChatCubit>(
        param1: ChatRouteArgs(
          title: args.clientName,
          conversationId: args.conversationId,
          coachClientId: args.coachClientId,
          canStartConversation: true,
        ),
      )..open(),
      child: Scaffold(
        body: CoachChatViewBody(contact: contact, chatArgs: args),
      ),
    );
  }
}
