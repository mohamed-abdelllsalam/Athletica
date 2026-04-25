import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';
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
          style: AppTextStyles.bold20(context)
              .copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: CoachClientsData.expiringClients.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  'All subscriptions are active. No upcoming expiries!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold20(context)
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
            )
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: CoachClientsData.expiringClients.length,
              separatorBuilder: (_, _) => SizedBox(height: 4.h),
              itemBuilder: (context, index) {
                return _ExpiringClientCard(
                  client: CoachClientsData.expiringClients[index],
                );
              },
            ),
    );
  }
}

class _ExpiringClientCard extends StatelessWidget {
  const _ExpiringClientCard({required this.client});

  final CoachClient client;

  static const _green = Color(0xFF4CAF50);
  static const _red = Color(0xFFFF5252);
  static const _purple = Color(0xFF7C4DFF);

  @override
  Widget build(BuildContext context) {
    final renewed = client.isRenewed ?? false;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 52.r,
              height: 52.r,
              color: AppColors.surfaceDark,
              child: client.imageAsset != null
                  ? Image.asset(client.imageAsset!, fit: BoxFit.cover)
                  : Icon(
                      Icons.person,
                      color: AppColors.textSecondary,
                      size: 28.sp,
                    ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: AppTextStyles.bold20(context)
                      .copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Expires in ${client.expiresInDays} days',
                  style: AppTextStyles.meduim12(context)
                      .copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: 2.h),
                Text(
                  renewed ? 'Renewed' : 'Not Renewed',
                  style: AppTextStyles.meduim12(context).copyWith(
                    color: renewed ? _green : _red,
                  ),
                ),
              ],
            ),
          ),
          if (renewed)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Renewed',
                  style: AppTextStyles.semiBold14(context)
                      .copyWith(color: _green),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.check, color: _green, size: 16.sp),
              ],
            )
          else
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              ),
              child: Text(
                'Send Reminder',
                style: AppTextStyles.semiBold14(context)
                    .copyWith(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
