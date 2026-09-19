import 'coach_join_requests_states.dart';
import 'coach_join_request_tile.dart';
import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
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
                style: AppTextStyles.medium15(
                  context,
                ).copyWith(color: AppColors.textPrimary),
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
      CoachJoinRequestsInitial() ||
      CoachJoinRequestsLoading() => const CoachJoinRequestsLoadingView(),
      CoachJoinRequestsError(:final message) => CoachJoinRequestsErrorView(
        message: message,
        onRetry: () => context.read<CoachJoinRequestsCubit>().loadRequests(),
      ),
      _ => _buildList(context, state.requests),
    };
  }

  Widget _buildList(BuildContext context, List<JoinRequest> requests) {
    final actingRequestId = switch (context
        .watch<CoachJoinRequestsCubit>()
        .state) {
      CoachJoinRequestsActionInProgress(:final actingRequestId) =>
        actingRequestId,
      _ => null,
    };

    if (requests.isEmpty) {
      return Center(
        child: Text(
          'No pending requests.',
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return CoachJoinRequestTile(
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
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
