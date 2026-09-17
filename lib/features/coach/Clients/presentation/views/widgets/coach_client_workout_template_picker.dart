import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/assign_plan_cubit.dart';
import 'package:athletica/features/coach/plan/presentation/views/customize_workout_assignment_view.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/domain/usecases/get_workout_template_detail_usecase.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_templates_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_templates_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ---------- Workout plan picker (full screen, inline assign) ----------

/// Full screen listing the coach's workout templates — same style as the
/// workout library — so a workout can be assigned without leaving the
/// client profile flow. Tapping a plan loads its full details (the list
/// API sends counts only) then pushes the sets/reps customization for
/// this client.
///
/// The list stays disabled until the roster is loaded and this client's
/// `coach_clients.id` relation id is resolved, so tapping a plan can
/// never hit a "still loading" state.
class CoachClientWorkoutTemplatePicker extends StatefulWidget {
  const CoachClientWorkoutTemplatePicker({
    super.key,
    required this.clientName,
    required this.clientEmail,
  });

  final String clientName;
  final String clientEmail;

  @override
  State<CoachClientWorkoutTemplatePicker> createState() =>
      _CoachClientWorkoutTemplatePickerState();
}

class _CoachClientWorkoutTemplatePickerState
    extends State<CoachClientWorkoutTemplatePicker> {
  String _query = '';
  String? _loadingId;

  List<WorkoutTemplateEntry> _filtered(List<WorkoutTemplateEntry> items) {
    if (_query.isEmpty) return items;
    final lower = _query.toLowerCase();
    return items
        .where(
          (t) =>
              t.title.toLowerCase().contains(lower) ||
              t.description.toLowerCase().contains(lower),
        )
        .toList();
  }

  Future<void> _pick(WorkoutTemplateEntry item, String relationId) async {
    if (_loadingId != null) return;
    setState(() => _loadingId = item.id);
    final result = await sl<GetWorkoutTemplateDetailUseCase>()(item.id);
    if (!mounted) return;
    switch (result) {
      case ApiError(:final failure):
        setState(() => _loadingId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
        );
      case ApiSuccess(:final data):
        setState(() => _loadingId = null);
        final assignedPlanId = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (_) => CustomizeWorkoutAssignmentView(
              template: data,
              coachClientId: relationId,
              clientName: widget.clientName,
            ),
          ),
        );
        if (!mounted) return;
        // Return the assigned plan info; the detail screen reloads the real
        // workout plan from the backend afterwards.
        if (assignedPlanId != null && assignedPlanId.isNotEmpty) {
          Navigator.pop(context, (
            planId: assignedPlanId,
            title: item.title,
            subtitle: item.description.isNotEmpty
                ? item.description
                : 'Workout Plan',
          ));
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search plans...',
                    hintStyle: AppTextStyles.medium14(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 20.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: BlocBuilder<WorkoutTemplatesCubit, WorkoutTemplatesState>(
                builder: (context, templatesState) {
                  return BlocBuilder<AssignPlanCubit, AssignPlanState>(
                    builder: (context, assignState) {
                      final items = switch (templatesState) {
                        WorkoutTemplatesLoaded(:final items) => items,
                        _ => null,
                      };
                      // coach_client_id must be the coach_clients.id relation
                      // id, resolved from the roster by the client's email.
                      final clients = switch (assignState) {
                        AssignPlanClientsLoaded(:final clients) => clients,
                        AssignPlanAssigning(:final clients) => clients,
                        AssignPlanError(:final clients) => clients,
                        _ => null,
                      };
                      if (items == null || clients == null) {
                        final templatesError =
                            templatesState is WorkoutTemplatesError
                            ? templatesState.message
                            : null;
                        final clientsError =
                            assignState is AssignPlanClientsError
                            ? assignState.message
                            : null;
                        final error = templatesError ?? clientsError;
                        if (error != null) return _buildError(error);
                        return const Center(child: CircularProgressIndicator());
                      }
                      final matchEmail = widget.clientEmail
                          .trim()
                          .toLowerCase();
                      final match = clients
                          .where(
                            (c) => c.email.trim().toLowerCase() == matchEmail,
                          )
                          .firstOrNull;
                      if (match == null) {
                        return _buildError(
                          'Client not found in your roster',
                          showRetry: false,
                        );
                      }
                      return _buildList(items, match.relationId);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'Select Workout Plan',
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message, {bool showRetry = true}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (showRetry) ...[
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  context.read<WorkoutTemplatesCubit>().load();
                  context.read<AssignPlanCubit>().loadClients();
                },
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<WorkoutTemplateEntry> items, String relationId) {
    final filtered = _filtered(items);
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No workout plans available',
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final item = filtered[index];
        final isLoading = item.id == _loadingId;
        return GestureDetector(
          onTap: () => _pick(item, relationId),
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.surfaceDark, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.fitness_center,
                          color: AppColors.primaryBlue,
                          size: 20.sp,
                        ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTextStyles.semiBold14(
                          context,
                        ).copyWith(color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${item.dayCount} days • ${item.exerciseCount} exercises',
                        style: AppTextStyles.meduim12(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
