import 'coach_client_deactivate_plan_dialog.dart';
import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/client_detail.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/client_detail_cubit.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_client_info_view.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';
import 'package:athletica/features/coach/messages/presentation/views/coach_chat_view.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/assign_plan_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_templates_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'coach_client_assigned_plans_section.dart';
import 'coach_client_profile_sections.dart';
import 'coach_client_progress_section.dart';
import 'coach_client_workout_template_picker.dart';

class CoachClientDetailViewBody extends StatefulWidget {
  const CoachClientDetailViewBody({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  final String clientId;
  final String clientName;

  @override
  State<CoachClientDetailViewBody> createState() =>
      _CoachClientDetailViewBodyState();
}

class _CoachClientDetailViewBodyState extends State<CoachClientDetailViewBody> {
  int _selectedTabIndex = 0;

  static const _tabs = ['Daily', 'Weekly', 'Monthly'];
  static const _dailyData = [0.80, 0.75, 0.45, 0.60, 0.75, 0.85, 0.95];
  static const _weeklyData = [0.50, 0.60, 0.70, 0.65, 0.80, 0.72, 0.90];
  static const _monthlyData = [0.30, 0.45, 0.55, 0.60, 0.70, 0.80, 0.85];
  static const _xLabels = ['Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Today'];

  List<double> get _currentData {
    switch (_selectedTabIndex) {
      case 1:
        return _weeklyData;
      case 2:
        return _monthlyData;
      default:
        return _dailyData;
    }
  }

  void _confirmDeactivate(BuildContext context, NutritionPlanSummary plan) {
    showDialog(
      context: context,
      builder: (dialogContext) => CoachClientDeactivatePlanDialog(
        message:
            'This will deactivate "${plan.title}" and remove all meal logs. The client will no longer see this plan.',
        onConfirm: () {
          Navigator.pop(dialogContext);
          context.read<ClientDetailCubit>().deleteNutritionPlan(plan.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: BlocBuilder<ClientDetailCubit, ClientDetailState>(
          builder: (context, state) {
            if (state is ClientDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ClientDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: AppTextStyles.medium14(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ClientDetailCubit>().loadClientDetail(
                          widget.clientId,
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is ClientDetailLoaded) {
              return _buildContent(context, state.detail);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ClientDetail detail) {
    final client = detail.client;
    return Column(
      children: [
        _buildAppBar(context, client),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                _buildProfileSection(context, client),
                SizedBox(height: 16.h),
                _buildMessageButton(context, client),
                SizedBox(height: 12.h),
                _buildInformationButton(context, detail),
                SizedBox(height: 24.h),
                _buildAssignedPlanSection(context, detail),
                SizedBox(height: 24.h),
                _buildProgressOverviewSection(context, detail),
                SizedBox(height: 8.h),
                Divider(color: AppColors.surfaceDark, thickness: 1),
                SizedBox(height: 8.h),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, ClientProfile client) {
    return CoachClientDetailAppBar(
      clientName: client.displayName,
      onBack: () => Navigator.pop(context),
    );
  }

  Widget _buildProfileSection(BuildContext context, ClientProfile client) {
    return CoachClientProfileSection(client: client);
  }

  Widget _buildMessageButton(BuildContext context, ClientProfile client) {
    return CoachClientMessageButton(
      clientName: client.displayName,
      onPressed: () {
        final contact = ChatContact(
          id: client.id,
          name: client.displayName,
          goals: client.goal != null ? [client.goal!] : [],
          heightCm: client.heightCm?.toInt(),
          weightKg: client.weightKg?.toInt(),
        );
        Navigator.pushNamed(
          context,
          CoachChatView.routeName,
          arguments: contact,
        );
      },
    );
  }

  Widget _buildInformationButton(BuildContext context, ClientDetail detail) {
    return CoachClientInformationButton(
      onPressed: () => Navigator.pushNamed(
        context,
        CoachClientInfoView.routeName,
        arguments: detail,
      ),
    );
  }

  void _confirmDeactivateWorkout(
    BuildContext context,
    String planId,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => CoachClientDeactivatePlanDialog(
        message:
            'This will deactivate "$title". The client will no longer see this plan.',
        onConfirm: () {
          Navigator.pop(dialogContext);
          context.read<ClientDetailCubit>().deleteWorkoutPlan(planId);
        },
      ),
    );
  }

  Widget _buildAssignedPlanSection(BuildContext context, ClientDetail detail) {
    final nutritionPlan = detail.nutritionPlan;
    final workoutPlan = detail.workoutPlan;
    final workoutTitle = workoutPlan?.title;
    final workoutSubtitle = (workoutPlan?.description?.isNotEmpty ?? false)
        ? workoutPlan!.description!
        : 'Workout Plan';
    final workoutPlanId = workoutPlan?.id;

    Future<void> reload() async {
      if (context.mounted) {
        context.read<ClientDetailCubit>().loadClientDetail(widget.clientId);
      }
    }

    return CoachClientAssignedPlansSection(
      nutritionPlan: nutritionPlan,
      workoutTitle: workoutTitle,
      workoutSubtitle: workoutSubtitle,
      onDeactivateNutrition: nutritionPlan == null
          ? null
          : () => _confirmDeactivate(context, nutritionPlan),
      onDeactivateWorkout: workoutPlanId == null || workoutTitle == null
          ? null
          : () =>
                _confirmDeactivateWorkout(context, workoutPlanId, workoutTitle),
      onAssignNutrition: () async {
        await Navigator.pushNamed(
          context,
          'nutrition-templates-list',
          arguments: {'clientId': detail.client.id},
        );
        await reload();
      },
      onAssignWorkout: () => _openWorkoutAssignSheet(context, detail),
    );
  }

  /// Opens the plan picker as a full screen (same style as the workout
  /// library) instead of navigating to the workout library screen itself.
  /// Picking a plan pushes the sets/reps customization for this client.
  Future<void> _openWorkoutAssignSheet(
    BuildContext context,
    ClientDetail detail,
  ) async {
    final assigned =
        await Navigator.push<({String planId, String title, String subtitle})>(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => sl<WorkoutTemplatesCubit>()..load(),
                ),
                BlocProvider(
                  create: (_) => sl<AssignPlanCubit>()..loadClients(),
                ),
              ],
              child: CoachClientWorkoutTemplatePicker(
                clientName: detail.client.displayName,
                clientEmail: detail.client.email,
              ),
            ),
          ),
        );
    if (assigned != null && context.mounted) {
      // The detail endpoint now returns the real workout plan, so a reload
      // shows the new assignment directly.
      await context.read<ClientDetailCubit>().loadClientDetail(widget.clientId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout assigned successfully')),
      );
    }
  }

  Widget _buildProgressOverviewSection(
    BuildContext context,
    ClientDetail detail,
  ) {
    return CoachClientProgressSection(
      detail: detail,
      tabs: _tabs,
      selectedIndex: _selectedTabIndex,
      dataPoints: _currentData,
      xLabels: _xLabels,
      onTabSelected: (index) => setState(() => _selectedTabIndex = index),
    );
  }
}

// ---------- Tab Selector ----------
