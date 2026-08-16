import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_cubit.dart';
import 'package:athletica/features/coach/clients/presentation/views/widgets/coach_clients_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachClientsView extends StatelessWidget {
  const CoachClientsView({super.key});

  static const String routeName = 'coach-clients';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CoachClientsCubit>(),
      child: const CoachClientsViewBody(),
    );
  }
}
