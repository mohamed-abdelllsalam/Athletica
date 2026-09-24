import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:athletica/features/chat/presentation/models/chat_route_args.dart';
import 'package:athletica/features/chat/presentation/views/widgets/chat_view_body.dart';
import 'package:athletica/features/client_coach/presentation/cubits/client_coach_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});
  static const String routeName = 'chatView';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final routeArgs = args is ChatRouteArgs
        ? args
        : const ChatRouteArgs(title: 'Coach');
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ChatCubit>(param1: routeArgs)..open(),
        ),
        BlocProvider(create: (_) => sl<ClientCoachCubit>()..loadCoach()),
      ],
      child: const ChatViewBody(),
    );
  }
}
