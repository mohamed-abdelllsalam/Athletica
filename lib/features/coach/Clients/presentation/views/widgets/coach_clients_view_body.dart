import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_clients_data.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_client_detail_view.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_join_requests_view.dart';
import 'package:athletica/features/coach/clients/presentation/views/widgets/coach_client_card.dart';
import 'package:athletica/features/coach/clients/presentation/views/widgets/coach_join_requests_banner.dart';
import 'package:flutter/material.dart';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CoachClient> get _filtered {
    if (_query.isEmpty) return CoachClientsData.clients;
    final lower = _query.toLowerCase();
    return CoachClientsData.clients
        .where((c) => c.name.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final clients = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
          child: Text(
            'Total Clients',
            style: AppTextStyles.bold24(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _SearchBar(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: CoachJoinRequestsBanner(
            count: 120,
            onTap: () => Navigator.pushNamed(
              context,
              CoachJoinRequestsView.routeName,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: clients.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final client = clients[index];
              return CoachClientCard(
                client: client,
                onTap: () => Navigator.pushNamed(
                  context,
                  CoachClientDetailView.routeName,
                  arguments: client,
                ),
              );
            },
          ),
        ),
      ],
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
