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
        body: SafeArea(
          child: _AssignPlanTemplatesViewBody(clientId: clientId),
        ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: BlocBuilder<NutritionTemplatesListCubit,
                NutritionTemplatesListState>(
              builder: (context, state) {
                if (state is NutritionTemplatesListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is NutritionTemplatesListError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<NutritionTemplatesListCubit>()
                                .loadTemplates();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is NutritionTemplatesListLoaded) {
                  if (state.plans.isEmpty) {
                    return const Center(
                      child: Text(
                        'No templates available.\nCreate a template first to assign a plan.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.plans.length,
                    itemBuilder: (context, index) {
                      final template = state.plans[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: AppColors.cardBackground,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.receipt_long,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          title: Text(
                            template.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            template.description,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.primaryBlue,
                          ),
                          onTap: () {
                            _assignDirectly(
                              context,
                              template.id,
                              template.name,
                              template.description,
                            );
                          },
                        ),
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Select Template',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No clients loaded')),
      );
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
