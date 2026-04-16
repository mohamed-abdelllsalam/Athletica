import 'package:athletica/features/coach/home/presentation/views/widgets/coach_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachStatsGrid extends StatelessWidget {
  const CoachStatsGrid({super.key});

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
                    value: '120',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CoachStatCard(
                    label: 'Active Clients',
                    value: '95',
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
                    value: '6',
                  ),
                ),
                SizedBox(width: 12.w),
                const Expanded(
                  child: CoachInviteCard(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
