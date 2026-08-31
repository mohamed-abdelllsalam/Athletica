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
    return all
        .where((c) => c.name.toLowerCase().contains(lower))
        .toList();
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
          style: AppTextStyles.bold20(context)
              .copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: _SearchBar(
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
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.message,
                          style: AppTextStyles.medium14(context)
                              .copyWith(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        OutlinedButton(
                          onPressed: () =>
                              context.read<CoachClientsCubit>().loadClients(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final clients = state.clients;
                final filtered = _filtered(clients);

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _query.isEmpty
                          ? 'No active clients yet'
                          : 'No clients match "$_query"',
                      style: AppTextStyles.medium14(context)
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  );
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.medium14(context).copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: AppTextStyles.medium14(context).copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }
}
