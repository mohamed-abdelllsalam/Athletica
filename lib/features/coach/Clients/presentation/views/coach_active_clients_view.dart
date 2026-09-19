import 'widgets/coach_active_clients_states.dart';
import 'widgets/coach_active_clients_search.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_assigned_client.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_cubit.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_state.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_client_detail_view.dart';
import 'package:athletica/features/coach/clients/presentation/views/widgets/coach_assigned_client_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachActiveClientsView extends StatefulWidget {
  const CoachActiveClientsView({super.key});

  static const String routeName = 'coach-active-clients';

  @override
  State<CoachActiveClientsView> createState() => _CoachActiveClientsViewState();
}

class _CoachActiveClientsViewState extends State<CoachActiveClientsView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<CoachClientsCubit>().loadClients();
  }

  List<CoachAssignedClient> _filtered(List<CoachAssignedClient> all) {
    if (_query.isEmpty) return all;
    final lower = _query.toLowerCase();
    return all.where((c) => c.name.toLowerCase().contains(lower)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryAppColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Active Clients',
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: CoachActiveClientsSearch(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: BlocBuilder<CoachClientsCubit, CoachClientsState>(
              builder: (context, state) {
                if (state is CoachClientsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                  );
                }

                if (state is CoachClientsError) {
                  return CoachActiveClientsError(
                    message: state.message,
                    onRetry: () =>
                        context.read<CoachClientsCubit>().loadClients(),
                  );
                }

                final clients = state.clients;
                final filtered = _filtered(clients);

                if (filtered.isEmpty) {
                  return CoachActiveClientsEmpty(query: _query);
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final client = filtered[index];
                    return CoachAssignedClientCard(
                      client: client,
                      onTap: () => Navigator.pushNamed(
                        context,
                        CoachClientDetailView.routeName,
                        arguments: {
                          'clientId': client.clientId,
                          'clientName': client.name,
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
