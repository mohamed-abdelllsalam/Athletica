import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/client_detail_cubit.dart';
import 'package:athletica/features/coach/clients/presentation/views/widgets/coach_client_detail_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachClientDetailView extends StatelessWidget {
  const CoachClientDetailView({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  static const String routeName = 'coach-client-detail';

  final String clientId;
  final String clientName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ClientDetailCubit>()..loadClientDetail(clientId),
      child: Scaffold(
        body: CoachClientDetailViewBody(
          clientId: clientId,
          clientName: clientName,
        ),
      ),
    );
  }
}
