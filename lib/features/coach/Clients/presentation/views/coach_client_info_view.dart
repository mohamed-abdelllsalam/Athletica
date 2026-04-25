import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';
import 'package:athletica/features/coach/clients/presentation/views/widgets/coach_client_info_view_body.dart';
import 'package:flutter/material.dart';

class CoachClientInfoView extends StatelessWidget {
  const CoachClientInfoView({super.key, required this.client});

  static const String routeName = 'coach-client-info';

  final CoachClient client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CoachClientInfoViewBody(client: client));
  }
}
