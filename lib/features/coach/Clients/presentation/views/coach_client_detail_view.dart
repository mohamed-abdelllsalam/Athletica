import 'package:athletica/core/widgets/refresh_on_focus.dart';
import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/client_detail_cubit.dart';
import 'package:athletica/features/coach/clients/presentation/views/widgets/coach_client_detail_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:athletica/features/streak/presentation/cubits/streak_cubit.dart';

class CoachClientDetailView extends StatelessWidget {
  const CoachClientDetailView({
    super.key,
    required this.clientId,
    required this.clientName,
    this.coachClientId,
  });

  static const String routeName = 'coach-client-detail';

  final String clientId;
  final String clientName;
  final String? coachClientId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<ClientDetailCubit>()..loadClientDetail(clientId),
        ),
        BlocProvider(
          create: (_) {
            final cubit = sl<StreakCubit>();
            if (coachClientId != null) {
              cubit.loadCoachClient(coachClientId!);
            } else {
              cubit.showError(
                'Client assignment is unavailable. Reopen this client from your client list.',
              );
            }
            return cubit;
          },
        ),
      ],
      child: Scaffold(
        body: Builder(
          builder: (context) => RefreshOnFocus(
            onRefresh: () => context.read<StreakCubit>().refresh(),
            child: CoachClientDetailViewBody(
              clientId: clientId,
              clientName: clientName,
              coachClientId: coachClientId,
            ),
          ),
        ),
      ),
    );
  }
}
