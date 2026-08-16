import 'package:athletica/features/coach/clients/presentation/views/coach_active_clients_view.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_expiring_subscriptions_view.dart';
import 'package:athletica/features/coach/home/presentation/views/widgets/coach_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachStatsGrid extends StatelessWidget {
  const CoachStatsGrid({
    super.key,
    required this.totalClients,
    required this.activeClients,
    required this.expiringSubscriptions,
    this.onTotalClientsTap,
    this.onInviteTap,
  });

  final String totalClients;
  final String activeClients;
  final String expiringSubscriptions;
  final VoidCallback? onTotalClientsTap;
  final VoidCallback? onInviteTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: CoachStatCard(
                    label: 'Total Clients',
                    value: totalClients,
                    onTap: onTotalClientsTap,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CoachStatCard(
                    label: 'Active Clients',
                    value: activeClients,
                    onTap: () => Navigator.pushNamed(
                      context,
                      CoachActiveClientsView.routeName,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: CoachStatCard(
                    label: 'Expiring\nSubscription',
                    value: expiringSubscriptions,
                    onTap: () => Navigator.pushNamed(
                      context,
                      CoachExpiringSubscriptionsView.routeName,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(child: CoachInviteCard(onTap: onInviteTap)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
