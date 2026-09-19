import 'widgets/coach_assign_template_card.dart';
import 'widgets/coach_assign_templates_header.dart';
import 'widgets/coach_assign_templates_states.dart';
import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
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
    final state = context.read<AssignPlanCubit>().state;
    final clients = state is AssignPlanClientsLoaded
        ? state.clients
        : (state is AssignPlanAssigning ? state.clients : null);

    if (clients == null || clients.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No clients loaded')));
      return;
    }

    final firstClient = clients.first;
    context.read<AssignPlanCubit>().assign(
      templateId: templateId,
      coachClientId: firstClient.relationId,
      title: templateName,
      description: templateDescription,
    );
  }
}
