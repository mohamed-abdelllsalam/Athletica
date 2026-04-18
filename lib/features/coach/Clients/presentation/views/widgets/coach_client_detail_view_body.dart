import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';
import 'package:athletica/features/coach/messages/presentation/views/coach_chat_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachClientDetailViewBody extends StatelessWidget {
  const CoachClientDetailViewBody({super.key, required this.client});

  final CoachClient client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _buildActionButtons(context),
                    SizedBox(height: 20.h),
                    _buildProfileCard(context),
                    SizedBox(height: 20.h),
                    _buildMessageButton(context),
                    SizedBox(height: 24.h),
                    _buildGoalsSection(context),
                    SizedBox(height: 24.h),
                    _buildProgressOverviewSection(context),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            client.name,
            style: AppTextStyles.semiBold15(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          icon: Icons.add,
          label: 'Add workout',
          onTap: () {},
        ),
        SizedBox(width: 12.w),
        _ActionButton(
          icon: Icons.add,
          label: 'Add Nutrition',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50.r),
          child: Container(
            width: 90.r,
            height: 90.r,
            color: AppColors.surfaceDark,
            child: client.imageAsset != null
                ? Image.asset(client.imageAsset!, fit: BoxFit.cover)
                : Icon(
                    Icons.person,
                    color: AppColors.textSecondary,
                    size: 40.sp,
                  ),
          ),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              client.name,
              style: AppTextStyles.bold20(context).copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _StatItem(
                  label: 'Height',
                  value: '${client.heightCm ?? '--'} Cm',
                  context: context,
                ),
                SizedBox(width: 24.w),
                _StatItem(
                  label: 'Weight',
                  value: '${client.weightKg ?? '--'} Kg',
                  context: context,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: () {
          final contact = ChatContactsData.contacts.firstWhere(
            (c) => c.id == client.id,
            orElse: () => ChatContact(
              id: client.id,
              name: client.name,
              goals: client.goals,
              heightCm: client.heightCm,
              weightKg: client.weightKg,
            ),
          );
          Navigator.pushNamed(
            context,
            CoachChatView.routeName,
            arguments: contact,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Message ${client.name.split(' ').first}',
          style: AppTextStyles.semiBold15(context).copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goals',
          style: AppTextStyles.bold20(context).copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        ...List.generate(client.goals.length, (i) {
          final isChecked = i < client.goals.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Container(
                  width: 22.r,
                  height: 22.r,
                  decoration: BoxDecoration(
                    color: isChecked
                        ? AppColors.primaryBlue
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4.r),
                    border: isChecked
                        ? null
                        : Border.all(
                            color: AppColors.textSecondary,
                            width: 1.5,
                          ),
                  ),
                  child: isChecked
                      ? Icon(
                          Icons.check,
                          color: AppColors.textPrimary,
                          size: 14.sp,
                        )
                      : null,
                ),
                SizedBox(width: 12.w),
                Text(
                  client.goals[i],
                  style: AppTextStyles.medium15(context).copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildProgressOverviewSection(BuildContext context) {
    const barHeights = [0.85, 0.45, 0.30, 0.20, 0.15, 0.35, 0.25, 0.40, 0.30];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Overview',
          style: AppTextStyles.bold20(context).copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Client lost 0.5kg this week',
          style: AppTextStyles.medium14(context).copyWith(
            color: AppColors.primaryBlue,
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 100.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: barHeights.map((ratio) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: FractionallySizedBox(
                    heightFactor: ratio,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42.h,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.primaryBlue, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                label,
                style: AppTextStyles.medium14(context).copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.context,
  });

  final String label;
  final String value;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.meduim12(context).copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTextStyles.medium14(context).copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
