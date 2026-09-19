import 'coach_clients_states.dart';
import 'coach_active_clients_search.dart';
import 'coach_remove_client_dialog.dart';
import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_assigned_client.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_cubit.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_state.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_join_requests_cubit.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_join_requests_state.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_client_detail_view.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_join_requests_view.dart';
import 'package:athletica/features/coach/clients/presentation/views/widgets/coach_assigned_client_card.dart';
import 'package:athletica/features/coach/clients/presentation/views/widgets/coach_join_requests_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachClientsViewBody extends StatefulWidget {
  const CoachClientsViewBody({super.key});

  @override
  State<CoachClientsViewBody> createState() => _CoachClientsViewBodyState();
}

class _CoachClientsViewBodyState extends State<CoachClientsViewBody> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<CoachClientsCubit>().loadClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<CoachAssignedClient> _filter(List<CoachAssignedClient> clients) {
    if (_query.isEmpty) return clients;
    final lower = _query.toLowerCase();
    return clients
        .where(
          (c) =>
              c.name.toLowerCase().contains(lower) ||
              c.email.toLowerCase().contains(lower),
        )
        .toList();
  }

  Future<void> _confirmRemove(
    BuildContext context,
    CoachAssignedClient client,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => CoachRemoveClientDialog(
        clientName: client.name,
        titleStyle: AppTextStyles.bold20(
          context,
        ).copyWith(color: AppColors.textPrimary),
        bodyStyle: AppTextStyles.medium14(
          context,
        ).copyWith(color: AppColors.textSecondary),
        onCancel: () => Navigator.pop(dialogContext, false),
        onConfirm: () => Navigator.pop(dialogContext, true),
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<CoachClientsCubit>().removeClient(client);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CoachJoinRequestsCubit>()..loadRequests(),
      child: BlocListener<CoachClientsCubit, CoachClientsState>(
        listenWhen: (previous, current) => current is CoachClientsActionError,
        listener: (context, state) {
          if (state is CoachClientsActionError) {
            _showSnackBar(context, state.message);
          }
        },
        child: BlocBuilder<CoachClientsCubit, CoachClientsState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  child: Text(
                    'Total Clients',
                    style: AppTextStyles.bold24(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: CoachActiveClientsSearch(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child:
                      BlocBuilder<
                        CoachJoinRequestsCubit,
                        CoachJoinRequestsState
                      >(
                        builder: (context, joinState) {
                          return CoachJoinRequestsBanner(
                            count: joinState.requests.length,
                            onTap: () async {
                              await Navigator.pushNamed(
                                context,
                                CoachJoinRequestsView.routeName,
                              );
                              if (context.mounted) {
                                context
                                    .read<CoachJoinRequestsCubit>()
                                    .loadRequests();
                                // Accepted/rejected requests change the roster,
                                // so reload it instead of showing stale data.
                                context.read<CoachClientsCubit>().loadClients();
                              }
                            },
                          );
                        },
                      ),
                ),
                SizedBox(height: 16.h),
                Expanded(child: _buildBody(state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(CoachClientsState state) {
    return switch (state) {
      CoachClientsInitial() ||
      CoachClientsLoading() => const CoachClientsLoadingView(),
      CoachClientsError(:final message) => CoachClientsErrorView(
        message: message,
        onRetry: () => context.read<CoachClientsCubit>().loadClients(),
      ),
      CoachClientsActionInProgress() ||
      CoachClientsLoaded() ||
      CoachClientsActionError() => _buildList(_filter(state.clients), state),
    };
  }

  Widget _buildList(
    List<CoachAssignedClient> clients,
    CoachClientsState state,
  ) {
    if (clients.isEmpty) {
      return Center(
        child: Text(
          _query.isEmpty ? 'No clients yet.' : 'No results for "$_query".',
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    final removingId = state is CoachClientsActionInProgress
        ? state.removingRelationId
        : null;

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: clients.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final client = clients[index];
        return Dismissible(
          key: ValueKey('coach-client-${client.relationId}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.delete_outline, color: Colors.white, size: 26.sp),
          ),
          confirmDismiss: (_) async {
            await _confirmRemove(context, client);
            return false;
          },
          child: CoachAssignedClientCard(
            client: client,
            removing: client.relationId == removingId,
            onTap: () {
              Navigator.pushNamed(
                context,
                CoachClientDetailView.routeName,
                arguments: {
                  'clientId': client.clientId,
                  'clientName': client.name,
                },
              );
            },
          ),
        );
      },
    );
  }
}
