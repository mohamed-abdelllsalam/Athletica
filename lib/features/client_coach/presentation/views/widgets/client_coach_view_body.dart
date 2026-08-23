import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:athletica/features/client_coach/domain/entities/assigned_coach.dart';
import 'package:athletica/features/client_coach/presentation/cubits/client_coach_cubit.dart';
import 'package:athletica/features/client_coach/presentation/cubits/client_coach_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientCoachViewBody extends StatefulWidget {
  const ClientCoachViewBody({super.key});

  @override
  State<ClientCoachViewBody> createState() => _ClientCoachViewBodyState();
}

class _ClientCoachViewBodyState extends State<ClientCoachViewBody> {
  final TextEditingController _tokenController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

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
      context.read<ClientCoachCubit>().leave();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClientCoachCubit, ClientCoachState>(
      listenWhen: (previous, current) =>
          current is ClientCoachRequestSent ||
          current is ClientCoachError &&
              previous is! ClientCoachError,
      listener: (context, state) {
        if (state is ClientCoachRequestSent) {
          _showSnackBar(context,
              'Request sent. Waiting for your coach to accept it.');
        } else if (state is ClientCoachError) {
          _showSnackBar(context, state.message);
        }
      },
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
        _JoinCoachForm(controller: _tokenController),
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

class _JoinCoachForm extends StatelessWidget {
  const _JoinCoachForm({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final submitting = context.watch<ClientCoachCubit>().state
        is ClientCoachSubmitting;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connect with your coach',
            style: AppTextStyles.bold20(context)
                .copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 8.h),
          Text(
            'Ask your coach for their invite link, then paste it below to '
            'send a connection request.',
            style: AppTextStyles.medium14(context)
                .copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: 24.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TextField(
              controller: controller,
              enabled: !submitting,
              style: AppTextStyles.medium14(context)
                  .copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Invite link or token',
                hintStyle: AppTextStyles.medium14(context)
                    .copyWith(color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.content_paste,
                    color: AppColors.textSecondary,
                    size: 20.sp,
                  ),
                  onPressed: submitting
                      ? null
                      : () async {
                          final data =
                              await Clipboard.getData(Clipboard.kTextPlain);
                          final text = data?.text;
                          if (text != null && text.trim().isNotEmpty) {
                            controller.text = text.trim();
                          }
                        },
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: submitting
                  ? null
                  : () => context.read<ClientCoachCubit>().submitToken(
                        controller.text,
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: submitting
                  ? SizedBox(
                      height: 22.h,
                      width: 22.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Send request',
                      style: AppTextStyles.medium14(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceDark,
                    border: Border.all(
                      color: AppColors.primaryBlue,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.fitness_center,
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
