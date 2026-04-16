import 'package:athletica/features/coach/Clients/presentation/views/widgets/coach_client_detail_view_body.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';
import 'package:flutter/material.dart';

class CoachClientDetailView extends StatelessWidget {
  const CoachClientDetailView({super.key, required this.client});

  static const String routeName = 'coach-client-detail';

  final CoachClient client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CoachClientDetailViewBody(client: client));
  }
}
