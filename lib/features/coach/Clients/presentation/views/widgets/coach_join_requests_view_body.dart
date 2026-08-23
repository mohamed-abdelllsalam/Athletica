import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:athletica/features/coach/clients/domain/entities/join_request.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_join_requests_cubit.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_join_requests_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachJoinRequestsViewBody extends StatelessWidget {
  const CoachJoinRequestsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CoachJoinRequestsCubit>()..loadRequests(),
      child: const Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        body: SafeArea(child: _CoachJoinRequestsContent()),
      ),
    );
  }
}

class _CoachJoinRequestsContent extends StatelessWidget {
  const _CoachJoinRequestsContent();

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CoachJoinRequestsCubit, CoachJoinRequestsState>(
      listenWhen: (previous, current) =>
          current is CoachJoinRequestsActionError,
      listener: (context, state) {
        if (state is CoachJoinRequestsActionError) {
          _showSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Text(
                'Request (${state.requests.length})',
                style: AppTextStyles.medium15(context).copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CoachJoinRequestsState state) {
    return switch (state) {
      CoachJoinRequestsInitial() || CoachJoinRequestsLoading() => AppShimmer(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 7,
            itemBuilder: (_, _) => Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: SkeletonListTile(),
            ),
          ),
        ),
      CoachJoinRequestsError(:final message) => Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    color: AppColors.textSecondary, size: 48.sp),
                SizedBox(height: 12.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.medium14(context)
                      .copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: 16.h),
                TextButton(
                  onPressed: () =>
                      context.read<CoachJoinRequestsCubit>().loadRequests(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      _ => _buildList(context, state.requests),
    };
  }

  Widget _buildList(BuildContext context, List<JoinRequest> requests) {
    final actingRequestId = switch (context.watch<CoachJoinRequestsCubit>().state) {
      CoachJoinRequestsActionInProgress(:final actingRequestId) =>
        actingRequestId,
      _ => null,
    };

    if (requests.isEmpty) {
      return Center(
        child: Text(
          'No pending requests.',
          style: AppTextStyles.medium14(context)
              .copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _RequestTile(
          request: request,
          busy: actingRequestId == request.id,
          actionInFlight: actingRequestId != null,
          onAccept: () =>
              context.read<CoachJoinRequestsCubit>().accept(request.id),
          onReject: () =>
              context.read<CoachJoinRequestsCubit>().reject(request.id),
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
            'Join Requests',
            style: AppTextStyles.semiBold15(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.request,
    required this.busy,
    required this.actionInFlight,
    required this.onAccept,
    required this.onReject,
  });

  final JoinRequest request;
  final bool busy;
  final bool actionInFlight;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40.r),
            child: Container(
              width: 54.r,
              height: 54.r,
              color: AppColors.surfaceDark,
              child: request.imageAsset != null
                  ? Image.asset(request.imageAsset!, fit: BoxFit.cover)
                  : Icon(
                      Icons.person,
                      color: AppColors.textSecondary,
                      size: 28.sp,
                    ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.name,
                  style: AppTextStyles.semiBold15(context).copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (request.goal.isNotEmpty)
                  Text(
                    request.goal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.meduim11(context).copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          _CircleIconButton(
            icon: Icons.close,
            iconColor: AppColors.textPrimary,
            borderColor: AppColors.textSecondary,
            onTap: actionInFlight ? null : onReject,
          ),
          SizedBox(width: 10.w),
          _CircleIconButton(
            icon: busy ? Icons.hourglass_top : Icons.check,
            iconColor: AppColors.primaryBlue,
            borderColor: AppColors.primaryBlue,
            onTap: busy || actionInFlight ? null : onAccept,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Icon(icon, color: iconColor, size: 18.sp),
      ),
    );
  }
}
