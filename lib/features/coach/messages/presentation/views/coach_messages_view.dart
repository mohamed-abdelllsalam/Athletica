import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/coach/messages/presentation/cubits/coach_messages_cubit.dart';
import 'package:athletica/features/coach/messages/presentation/views/widgets/coach_messages_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachMessagesView extends StatelessWidget {
  const CoachMessagesView({super.key});

  static const String routeName = 'coach-messages';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CoachMessagesCubit>()..load(),
      child: const CoachMessagesViewBody(),
    );
  }
}
