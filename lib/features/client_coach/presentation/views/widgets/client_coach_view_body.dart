import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:athletica/features/achievements/presentation/views/widgets/client_coach_achievements_section.dart';
import 'package:athletica/features/client_coach/domain/entities/assigned_coach.dart';
import 'package:athletica/features/client_coach/presentation/cubits/client_coach_cubit.dart';
import 'package:athletica/features/client_coach/presentation/cubits/client_coach_state.dart';
import 'package:athletica/features/client_coach/presentation/views/widgets/coach_code_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientCoachViewBody extends StatefulWidget {
  const ClientCoachViewBody({super.key});

  @override
  State<ClientCoachViewBody> createState() => _ClientCoachViewBodyState();
}

class _ClientCoachViewBodyState extends State<ClientCoachViewBody> {
  Future<void> _confirmLeave(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Leave coach?',
          style: AppTextStyles.semiBold15(dialogContext)
              .copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Leaving your coach will remove all your nutrition and workout '
          'plan data. This cannot be undone.',
          style: AppTextStyles.medium14(dialogContext)
              .copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final left = await context.read<ClientCoachCubit>().leave();
      // Back to the previous (home) screen once the leave succeeded.
      if (left && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientCoachCubit, ClientCoachState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.primaryAppColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context),
                Expanded(child: _buildBody(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 24.sp,
              ),
            ),
          ),
          Text(
            'My Coach',
            style: AppTextStyles.semiBold15(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ClientCoachState state) {
    return switch (state) {
      ClientCoachInitial() || ClientCoachLoading() => AppShimmer(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 220.h, radius: 16.r),
                SizedBox(height: 24.h),
                SkeletonBox(height: 50.h, radius: 12.r),
              ],
            ),
          ),
        ),
      ClientCoachLoaded(:final coach) =>
        _CoachCard(coach: coach, onLeave: () => _confirmLeave(context)),
      ClientCoachNoCoach() ||
      ClientCoachSubmitting() ||
      ClientCoachRequestSent() =>
        const _JoinCoachSection(),
      ClientCoachError() => Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    color: AppColors.textSecondary, size: 48.sp),
                SizedBox(height: 12.h),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.medium14(context)
                      .copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: 16.h),
                TextButton(
                  onPressed: () =>
                      context.read<ClientCoachCubit>().loadCoach(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
    };
  }
}

class _JoinCoachSection extends StatelessWidget {
  const _JoinCoachSection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Connect with your coach',
              textAlign: TextAlign.center,
              style: AppTextStyles.bold20(context)
                  .copyWith(color: AppColors.textPrimary),
            ),
            SizedBox(height: 8.h),
            Text(
              "You don't have a coach yet. Get your coach's 6-character "
              'code, then subscribe below to send a connection request.',
              textAlign: TextAlign.center,
              style: AppTextStyles.medium14(context)
                  .copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () async {
                final sent = await showCoachCodeDialog(context);
                if (sent && context.mounted) {
                  context.read<ClientCoachCubit>().loadCoach();
                }
              },
              child: Text.rich(
                TextSpan(
                  text: "You don't have one. ",
                  style: AppTextStyles.medium15(context)
                      .copyWith(color: AppColors.textSecondary),
                  children: [
                    TextSpan(
                      text: 'Subscribe',
                      style: AppTextStyles.semiBold15(context).copyWith(
                        color: AppColors.primaryBlue,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({required this.coach, required this.onLeave});

  final AssignedCoach coach;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Container(
                  width: 72.r,
                  height: 72.r,
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceDark,
                    border: Border.all(
                      color: AppColors.primaryBlue,
                      width: 2,
                    ),
                  ),
                  child: coach.hasPhoto
                      ? Image.network(
                          coach.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.person,
                            color: AppColors.textSecondary,
                            size: 32.sp,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: AppColors.textSecondary,
                          size: 32.sp,
                        ),
                ),
                SizedBox(height: 12.h),
                Text(
                  coach.username,
                  style: AppTextStyles.bold20(context)
                      .copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(height: 4.h),
                Text(
                  coach.email,
                  style: AppTextStyles.medium14(context)
                      .copyWith(color: AppColors.textSecondary),
                ),
                if (coach.specialization.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      coach.specialization,
                      style: AppTextStyles.meduim12(context)
                          .copyWith(color: AppColors.primaryBlue),
                    ),
                  ),
                ],
                if (coach.bio.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Text(
                    coach.bio,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.medium14(context)
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
                if (coach.assignedAt != null) ...[
                  SizedBox(height: 16.h),
                  Text(
                    'Coaching since ${_formatDate(coach.assignedAt!)}',
                    style: AppTextStyles.meduim12(context)
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 24.h),
          const ClientCoachAchievementsSection(),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: OutlinedButton(
              onPressed: onLeave,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Leave coach',
                style: AppTextStyles.medium14(context).copyWith(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
