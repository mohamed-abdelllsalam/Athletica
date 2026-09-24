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
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CoachHeroCard(coach: coach),
          SizedBox(height: 24.h),
          if (coach.bio.isNotEmpty) ...[
            _SectionHeading(
              title: 'About your coach',
              subtitle: 'Get to know the person guiding your progress',
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: Colors.white.withValues(alpha: .06)),
              ),
              child: Text(
                coach.bio,
                style: AppTextStyles.medium14(context).copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
          _SectionHeading(
            title: 'Credentials',
            subtitle: 'Certificates and qualifications',
          ),
          SizedBox(height: 12.h),
          const ClientCoachAchievementsSection(),
          SizedBox(height: 28.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: Colors.redAccent.withValues(alpha: .2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.link_off_rounded,
                    color: Colors.redAccent,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your coaching connection',
                        style: AppTextStyles.semiBold15(context)
                            .copyWith(color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Leaving removes your plans and coaching data.',
                        style: AppTextStyles.meduim12(context)
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                TextButton(
                  onPressed: onLeave,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                  ),
                  child: const Text('Leave'),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          if (coach.assignedAt != null)
            Center(
              child: Text(
                'Coaching together since ${_formatDate(coach.assignedAt!)}',
                style: AppTextStyles.meduim12(context)
                    .copyWith(color: AppColors.textTertiary),
              ),
            ),
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

class _CoachHeroCard extends StatelessWidget {
  const _CoachHeroCard({required this.coach});

  final AssignedCoach coach;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF282044), AppColors.cardBackground, Color(0xFF191919)],
        ),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: .32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: .12),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 82.r,
                height: 82.r,
                padding: EdgeInsets.all(3.r),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                  ),
                ),
                child: ClipOval(
                  child: ColoredBox(
                    color: AppColors.surfaceDark,
                    child: coach.hasPhoto
                        ? Image.network(
                            coach.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _CoachPlaceholder(),
                          )
                        : _CoachPlaceholder(),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.streakGreen.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              color: AppColors.streakGreen, size: 13.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'YOUR COACH',
                            style: AppTextStyles.meduim12(context).copyWith(
                              color: AppColors.streakGreen,
                              letterSpacing: .6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      coach.username,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bold20(context)
                          .copyWith(color: AppColors.textPrimary),
                    ),
                    if (coach.specialization.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        coach.specialization,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.medium14(context)
                            .copyWith(color: AppColors.primaryBlue),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(height: 1, color: Colors.white.withValues(alpha: .08)),
          SizedBox(height: 14.h),
          Row(
            children: [
              Icon(Icons.mail_outline_rounded,
                  size: 17.sp, color: AppColors.textTertiary),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  coach.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.medium14(context)
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          if (coach.assignedAt != null) ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(Icons.calendar_month_outlined,
                    size: 17.sp, color: AppColors.textTertiary),
                SizedBox(width: 8.w),
                Text(
                  'Coaching since ${_formatDate(coach.assignedAt!)}',
                  style: AppTextStyles.meduim12(context)
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
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

class _CoachPlaceholder extends StatelessWidget {
  const _CoachPlaceholder();

  @override
  Widget build(BuildContext context) => Icon(
        Icons.person_rounded,
        color: AppColors.textSecondary,
        size: 38.sp,
      );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bold20(context)
              .copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 3.h),
        Text(
          subtitle,
          style: AppTextStyles.meduim12(context)
              .copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
