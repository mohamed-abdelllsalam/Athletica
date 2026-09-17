import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/assigned_client.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/assign_plan_cubit.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionPlanAssignClientSheet extends StatefulWidget {
  const NutritionPlanAssignClientSheet({super.key, required this.plan});

  final NutritionPlan plan;

  @override
  State<NutritionPlanAssignClientSheet> createState() =>
      _NutritionPlanAssignClientSheetState();
}

class _NutritionPlanAssignClientSheetState
    extends State<NutritionPlanAssignClientSheet> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedClientId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submit(AssignPlanState state) {
    if (state is AssignPlanAssigning) return;
    final clients = switch (state) {
      AssignPlanClientsLoaded(:final clients) => clients,
      AssignPlanError(:final clients) => clients,
      _ => <AssignedClient>[],
    };
    final selectedId = _selectedClientId;
    if (selectedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a client',
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.buttonColor,
        ),
      );
      return;
    }
    final selected = clients
        .where((c) => c.relationId == selectedId)
        .firstOrNull;
    if (selected == null) return;
    context.read<AssignPlanCubit>().assign(
      templateId: widget.plan.id,
      coachClientId: selected.relationId,
      title: widget.plan.name.isEmpty ? 'Nutrition Plan' : widget.plan.name,
      description: widget.plan.description.isEmpty
          ? 'Nutrition Plan'
          : widget.plan.description,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssignPlanCubit, AssignPlanState>(
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        switch (state) {
          case AssignPlanSuccess():
            Navigator.pop(context);
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  'Plan assigned successfully',
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
            );
          case AssignPlanError(:final message):
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  message,
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          default:
            break;
        }
      },
      builder: (context, state) {
        Widget body;
        switch (state) {
          case AssignPlanInitial():
          case AssignPlanClientsLoading():
            body = SizedBox(
              height: 200.h,
              child: AppShimmer(
                child: Row(
                  children: [
                    for (var i = 0; i < 4; i++) ...[
                      if (i > 0) SizedBox(width: 16.w),
                      SkeletonBox(width: 56.w, height: 72.h, radius: 28.r),
                    ],
                  ],
                ),
              ),
            );
          case AssignPlanClientsError(:final message):
            body = SizedBox(
              height: 200.h,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: AppTextStyles.medium14(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<AssignPlanCubit>().loadClients(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                      ),
                      child: Text(
                        'Retry',
                        style: AppTextStyles.medium14(
                          context,
                        ).copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          default:
            body = _buildClientPicker(context, state);
        }

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
                body,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClientPicker(BuildContext context, AssignPlanState state) {
    final clients = switch (state) {
      AssignPlanClientsLoaded(:final clients) => clients,
      AssignPlanAssigning(:final clients) => clients,
      AssignPlanError(:final clients) => clients,
      _ => <AssignedClient>[],
    };
    final isAssigning = state is AssignPlanAssigning;
    final query = _searchController.text.toLowerCase();
    final filtered = clients
        .where((c) => query.isEmpty || c.name.toLowerCase().contains(query))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              hintText: 'Search',
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
        SizedBox(height: 16.h),
        SizedBox(
          height: 80.h,
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'No assigned clients found',
                    style: AppTextStyles.meduim12(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => SizedBox(width: 16.w),
                  itemBuilder: (context, index) {
                    final client = filtered[index];
                    final isSelected = _selectedClientId == client.relationId;
                    final name = client.name;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedClientId = client.relationId),
                      child: Column(
                        children: [
                          Container(
                            width: 48.r,
                            height: 48.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceDark,
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.primaryBlue,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                              size: 26.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          SizedBox(
                            width: 56.w,
                            child: Text(
                              name.split(' ').first,
                              style: AppTextStyles.meduim11(
                                context,
                              ).copyWith(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: isAssigning ? null : () => _submit(state),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: isAssigning
                ? SizedBox(
                    height: 22.h,
                    width: 22.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Submit',
                    style: AppTextStyles.medium14(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

// ── Template meta editor (view mode) ─────────────────────────────────────────

/// Edit sheet for a persisted template's name/description
/// (`PUT /nutrition/templates/:id`). Returns `null` from [onSave] on success;
/// a string is surfaced inline as the failure reason.
