import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_cubit.dart';
import 'package:athletica/features/coach/clients/presentation/views/widgets/coach_clients_view_body.dart';
import 'package:athletica/features/coach/home/presentation/cubits/coach_home_stats_cubit.dart';
import 'package:athletica/features/coach/home/presentation/cubits/coach_home_stats_state.dart';
import 'package:athletica/features/coach/home/presentation/cubits/coach_invite_cubit.dart';
import 'package:athletica/features/coach/home/presentation/cubits/coach_invite_state.dart';
import 'package:athletica/features/coach/home/presentation/views/widgets/coach_bottom_nav_bar.dart';
import 'package:athletica/features/coach/home/presentation/views/widgets/coach_home_app_bar.dart';
import 'package:athletica/features/coach/home/presentation/views/widgets/coach_insights_section.dart';
import 'package:athletica/features/coach/home/presentation/views/widgets/coach_stats_grid.dart';
import 'package:athletica/features/coach/home/presentation/views/widgets/invite_code_dialog.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/coach_plan_view_body.dart';
import 'package:athletica/features/coach/profile/presentation/cubits/coach_profile_cubit.dart';
import 'package:athletica/features/coach/profile/presentation/views/widgets/coach_profile_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachHomeViewBody extends StatefulWidget {
  const CoachHomeViewBody({super.key});

  @override
  State<CoachHomeViewBody> createState() => _CoachHomeViewBodyState();
}

class _CoachHomeViewBodyState extends State<CoachHomeViewBody> {
  // Local UI state — no business logic
  int _selectedPeriod = 0; // 0 = Daily, 1 = Monthly
  int _selectedNavIndex = 0;
  late final CoachHomeStatsCubit _statsCubit;
  late final CoachInviteCubit _inviteCubit;

  /// True while the invite dialog is open. It reloads itself on regenerate,
  /// so the listener must not stack another dialog or duplicate its errors.
  bool _inviteDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _statsCubit = sl<CoachHomeStatsCubit>()..loadStats();
    _inviteCubit = sl<CoachInviteCubit>();
  }

  @override
  void dispose() {
    _statsCubit.close();
    _inviteCubit.close();
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          const CoachHomeAppBar(),
          SizedBox(height: 20.h),
          BlocBuilder<CoachHomeStatsCubit, CoachHomeStatsState>(
            builder: (context, state) {
              final stats = switch (state) {
                CoachHomeStatsLoaded(:final stats) => stats,
                _ => null,
              };
              final totalClients = stats?.totalClients.toString() ?? '--';
              final activeClients = stats?.activeClients.toString() ?? '--';
              final expiringSubscriptions =
                  stats?.expiringSubscriptions.toString() ?? '--';

              return CoachStatsGrid(
                totalClients: totalClients,
                activeClients: activeClients,
                expiringSubscriptions: expiringSubscriptions,
                onTotalClientsTap: () => setState(() => _selectedNavIndex = 1),
                onInviteTap: () =>
                    context.read<CoachInviteCubit>().createInviteLink(),
              );
            },
          ),
          SizedBox(height: 28.h),
          CoachInsightsSection(
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: (index) {
              setState(() => _selectedPeriod = index);
            },
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _statsCubit),
        BlocProvider.value(value: _inviteCubit),
      ],
      child: BlocListener<CoachInviteCubit, CoachInviteState>(
        listenWhen: (previous, current) =>
            current is CoachInviteSuccess ||
            current is CoachInviteError ||
            current is CoachInviteRevoked,
        listener: (context, state) async {
          if (state is CoachInviteSuccess) {
            // An open dialog reloads itself on regenerate — never stack.
            if (_inviteDialogOpen) return;
            _inviteDialogOpen = true;
            await showDialog<void>(
              context: context,
              builder: (_) => InviteCodeDialog(
                invite: state.invite,
                inviteCubit: _inviteCubit,
              ),
            );
            _inviteDialogOpen = false;
          } else if (state is CoachInviteRevoked) {
            _showSnackBar(context, 'Invite link revoked.');
          } else if (state is CoachInviteError) {
            // The open dialog already surfaces regenerate errors inline.
            if (_inviteDialogOpen) return;
            _showSnackBar(context, state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.primaryAppColor,
          body: SafeArea(
            child: IndexedStack(
              index: _selectedNavIndex,
              children: [
                _buildHomeTab(),
                BlocProvider(
                  create: (_) => sl<CoachClientsCubit>(),
                  child: const CoachClientsViewBody(),
                ),
                const CoachPlanViewBody(),
                MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => sl<AuthCubit>()),
                    BlocProvider(create: (_) => sl<CoachProfileCubit>()..loadProfile()),
                  ],
                  child: const CoachProfileViewBody(),
                ),
              ],
            ),
          ),
          bottomNavigationBar: CoachBottomNavBar(
            selectedIndex: _selectedNavIndex,
            onTap: (index) => setState(() => _selectedNavIndex = index),
          ),
        ),
      ),
    );
  }
}
