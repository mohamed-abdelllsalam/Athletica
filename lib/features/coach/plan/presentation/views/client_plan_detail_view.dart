import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/plan/domain/entities/coach_plan_client.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/client_plan_detail_view_body.dart';
import 'package:flutter/material.dart';

class ClientPlanDetailView extends StatelessWidget {
  const ClientPlanDetailView({super.key, required this.client});

  static const String routeName = 'client-plan-detail';

  final CoachPlanClient client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(child: ClientPlanDetailViewBody(client: client)),
    );
  }
}
