import 'dart:async';

import 'widgets/coach_assign_template_card.dart';
import 'widgets/coach_assign_templates_header.dart';
import 'widgets/coach_assign_templates_states.dart';
import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/assigned_client.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/assign_plan_cubit.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/nutrition_templates_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssignPlanTemplatesView extends StatelessWidget {
  const AssignPlanTemplatesView({super.key, required this.clientId});

  static const String routeName = 'nutrition-templates-list';

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: sl<NutritionTemplatesListCubit>()..loadTemplates(),
        ),
        BlocProvider(create: (_) => sl<AssignPlanCubit>()..loadClients()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        body: SafeArea(child: _AssignPlanTemplatesViewBody(clientId: clientId)),
      ),
    );
  }
}

class _AssignPlanTemplatesViewBody extends StatelessWidget {
  const _AssignPlanTemplatesViewBody({required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssignPlanCubit, AssignPlanState>(
      listener: (context, state) {
        if (state is AssignPlanSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plan assigned successfully!')),
          );
          Navigator.pop(context);
        } else if (state is AssignPlanError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Column(
        children: [
          CoachAssignTemplatesHeader(onBack: () => Navigator.pop(context)),
          Expanded(
            child:
                BlocBuilder<
                  NutritionTemplatesListCubit,
                  NutritionTemplatesListState
                >(
                  builder: (context, state) {
                    if (state is NutritionTemplatesListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is NutritionTemplatesListError) {
                      return CoachAssignTemplatesError(
                        message: state.message,
                        onRetry: () {
                          context
                              .read<NutritionTemplatesListCubit>()
                              .loadTemplates();
                        },
                      );
                    }

                    if (state is NutritionTemplatesListLoaded) {
                      if (state.plans.isEmpty) {
                        return const CoachAssignTemplatesEmpty();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.plans.length,
                        itemBuilder: (context, index) {
                          final template = state.plans[index];
                          return CoachAssignTemplateCard(
                            template: template,
                            onTap: () {
                              _assignDirectly(
                                context,
                                template.id,
                                template.name,
                                template.description,
                              );
                            },
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
          ),
        ],
      ),
    );
  }

  void _assignDirectly(
    BuildContext context,
    String templateId,
    String templateName,
    String templateDescription,
  ) {
    // Fire-and-forget: all outcomes (including errors) are reported via
    // snackbars inside; the future never throws.
    _assignWhenReady(context, templateId, templateName, templateDescription);
  }

  Future<void> _assignWhenReady(
    BuildContext context,
    String templateId,
    String templateName,
    String templateDescription,
  ) async {
    final cubit = context.read<AssignPlanCubit>();
    final clients = await _readyClients(context, cubit);
    if (!context.mounted) return;
    if (clients == null) return; // Message already shown.
    if (clients.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No clients loaded')));
      return;
    }

    final match = findRosterMatch(clients, clientId);
    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client not found in your roster')),
      );
      return;
    }

    cubit.assign(
      templateId: templateId,
      coachClientId: match.relationId,
      title: templateName,
      description: templateDescription,
    );
  }

  /// Returns the loaded roster, waiting for the in-flight fetch when the user
  /// taps a template before it finishes. Returns null (after showing the
  /// relevant message) when the roster failed to load.
  Future<List<AssignedClient>?> _readyClients(
    BuildContext context,
    AssignPlanCubit cubit,
  ) async {
    final current = cubit.state;
    if (current is AssignPlanClientsLoaded) return current.clients;
    if (current is AssignPlanAssigning) return current.clients;
    if (current is AssignPlanClientsError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(current.message)));
      return null;
    }

    try {
      final pending = cubit.stream.firstWhere(
        (s) => s is AssignPlanClientsLoaded || s is AssignPlanClientsError,
      );
      // Safe no-op while a load is already in flight; starts one otherwise.
      cubit.loadClients();
      final settled = await pending.timeout(const Duration(seconds: 20));
      if (settled is AssignPlanClientsLoaded) return settled.clients;
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((settled as AssignPlanClientsError).message)),
      );
      return null;
    } on TimeoutException {
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Still loading clients, please try again'),
        ),
      );
      return null;
    } on StateError {
      // Cubit closed before the roster settled.
      return null;
    }
  }
}
