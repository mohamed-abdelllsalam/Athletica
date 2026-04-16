import 'package:athletica/features/coach/clients/presentation/views/widgets/coach_clients_view_body.dart';
import 'package:flutter/material.dart';

class CoachClientsView extends StatelessWidget {
  const CoachClientsView({super.key});

  static const String routeName = 'coach-clients';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CoachClientsViewBody());
  }
}
