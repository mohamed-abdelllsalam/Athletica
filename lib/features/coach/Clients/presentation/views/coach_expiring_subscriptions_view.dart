import 'widgets/coach_expiring_client_card.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_clients_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachExpiringSubscriptionsView extends StatelessWidget {
  const CoachExpiringSubscriptionsView({super.key});

  static const String routeName = 'coach-expiring-subscriptions';

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
          'Expiring Subscription',
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: CoachClientsData.expiringClients.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  'All subscriptions are active. No upcoming expiries!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold20(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
              ),
            )
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: CoachClientsData.expiringClients.length,
              separatorBuilder: (_, _) => SizedBox(height: 4.h),
              itemBuilder: (context, index) {
                return CoachExpiringClientCard(
                  client: CoachClientsData.expiringClients[index],
                );
              },
            ),
    );
  }
}
