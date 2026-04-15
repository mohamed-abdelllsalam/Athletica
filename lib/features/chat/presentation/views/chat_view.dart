import 'package:athletica/features/chat/presentation/views/widgets/chat_view_body.dart';
import 'package:flutter/material.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});
  static const String routeName = 'chatView';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ChatViewBody(),
    );
  }
}
