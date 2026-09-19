import 'workout_assignment_client_components.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_assigned_client.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_cubit.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_state.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_plans_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_plans_state.dart';
import 'package:athletica/features/workout/presentation/views/workout_plan_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutPlanAssignClientSheet extends StatefulWidget {
  const WorkoutPlanAssignClientSheet({super.key, required this.template});

  final WorkoutTemplateEntry template;

  @override
  State<WorkoutPlanAssignClientSheet> createState() =>
      _WorkoutPlanAssignClientSheetState();
}

class _WorkoutPlanAssignClientSheetState
    extends State<WorkoutPlanAssignClientSheet> {
  late final TextEditingController _searchController;
  String? _selectedRelationId;
  String? _selectedClientName;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Client picked — hand off to the Customize Workout Assignment page,
  /// which performs the actual assignment on confirm.
  void _continue() {
    final relationId = _selectedRelationId;
    final clientName = _selectedClientName;
    if (relationId == null || clientName == null) return;
    Navigator.pop(context, (relationId: relationId, clientName: clientName));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Assign "${widget.template.title}"',
              style: AppTextStyles.semiBold15(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            SizedBox(height: 12.h),
            Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search clients',
                  hintStyle: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                    size: 20.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            BlocBuilder<CoachClientsCubit, CoachClientsState>(
              builder: (context, state) {
                final clients = state.clients;
                if (state is CoachClientsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CoachClientsError) {
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          state.message,
                          style: AppTextStyles.medium14(
                            context,
                          ).copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.read<CoachClientsCubit>().loadClients(),
                        child: const Text('Retry'),
                      ),
                    ],
                  );
                }
                final query = _searchController.text.toLowerCase();
                final filtered = clients
                    .where(
                      (c) =>
                          query.isEmpty || c.name.toLowerCase().contains(query),
                    )
                    .toList();
                if (filtered.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      'No clients found',
                      style: AppTextStyles.medium14(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                  );
                }
                return SizedBox(
                  height: 88.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => SizedBox(width: 16.w),
                    itemBuilder: (context, index) {
                      final CoachAssignedClient client = filtered[index];
                      final isSelected =
                          _selectedRelationId == client.relationId;
                      return CoachWorkoutAssignmentClientAvatar(
                        name: client.name,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedRelationId = client.relationId;
                            _selectedClientName = client.name;
                          });
                          context.read<WorkoutPlansCubit>().load(
                            clientId: client.relationId,
                            isActive: true,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 12.h),
            BlocBuilder<WorkoutPlansCubit, WorkoutPlansState>(
              builder: (context, plansState) {
                if (_selectedRelationId == null) {
                  return const SizedBox.shrink();
                }
                return switch (plansState) {
                  WorkoutPlansInitial() => const SizedBox.shrink(),
                  WorkoutPlansLoading() => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox.square(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  WorkoutPlansError() => const SizedBox.shrink(),
                  WorkoutPlansLoaded(:final items) =>
                    items.isEmpty
                        ? const SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active plans for this client',
                                style: AppTextStyles.meduim12(
                                  context,
                                ).copyWith(color: AppColors.textSecondary),
                              ),
                              SizedBox(height: 8.h),
                              ...items.map(
                                (plan) => CoachWorkoutAssignmentActivePlan(
                                  title: plan.title,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => WorkoutPlanDetailScreen(
                                        planId: plan.id,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                };
              },
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _selectedRelationId == null ? null : _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: AppTextStyles.semiBold14(
                    context,
                  ).copyWith(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
