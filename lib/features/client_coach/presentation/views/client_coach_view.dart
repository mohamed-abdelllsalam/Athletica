import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/achievements/presentation/cubits/client_coach_achievements_cubit.dart';
import 'package:athletica/features/client_coach/presentation/cubits/client_coach_cubit.dart';
import 'package:athletica/features/client_coach/presentation/views/widgets/client_coach_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientCoachView extends StatelessWidget {
  const ClientCoachView({super.key});

  static const String routeName = 'client-coach';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ClientCoachCubit>()..loadCoach()),
        BlocProvider(create: (_) => sl<ClientCoachAchievementsCubit>()),
      ],
      child: const ClientCoachViewBody(),
    );
  }
}
