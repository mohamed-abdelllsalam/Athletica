import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/widgets/connection_error_view.dart';
import 'package:athletica/core/widgets/refresh_on_focus.dart';
import 'package:athletica/core/widgets/streak_row.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/streak/domain/entities/streak_data.dart';
import 'package:athletica/features/streak/presentation/cubits/streak_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StreakSection extends StatelessWidget {
  const StreakSection({
    super.key,
    this.data,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.showHeader = true,
  });

  final StreakData? data;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    Widget buildForState(StreakState state) {
      final currentData = data ?? (state is StreakLoaded ? state.data : null);
      final loading = isLoading || state is StreakLoading;
      final error =
          errorMessage ?? (state is StreakError ? state.message : null);
      final empty = state is StreakEmpty;
      final content = _buildContent(
        context,
        currentData,
        loading,
        error,
        empty,
      );
      if (state is StreakError && state.isConnectionError) {
        return ConnectionErrorView(
          onRetry: onRetry ?? () => context.read<StreakCubit>().refresh(),
          compact: true,
        );
      }
      if (state is StreakLoaded &&
          state.isConnectionError &&
          state.data.workoutFailure == null &&
          state.data.nutritionFailure == null) {
        return ConnectionErrorSection(
          hasError: true,
          onRetry: onRetry ?? () => context.read<StreakCubit>().refresh(),
          child: content,
        );
      }
      return content;
    }

    try {
      context.read<StreakCubit>();
    } on ProviderNotFoundException {
      return _buildContent(context, data, isLoading, errorMessage, false);
    }
    return RefreshOnFocus(
      onRefresh: () => context.read<StreakCubit>().refresh(),
      child: BlocBuilder<StreakCubit, StreakState>(
        builder: (context, state) => buildForState(state),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    StreakData? data,
    bool loading,
    String? error,
    bool empty,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[_buildHeader(context), SizedBox(height: 16.h)],
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (error != null && data == null)
            Row(
              children: [
                Expanded(child: Text(error)),
                TextButton(
                  onPressed:
                      onRetry ?? () => context.read<StreakCubit>().refresh(),
                  child: const Text('Retry'),
                ),
              ],
            )
          else if (empty)
            Text(
              'No streak activity yet',
              style: AppTextStyles.medium13(
                context,
              ).copyWith(color: AppColors.textSecondary),
            )
          else if (data != null) ...[
            if (data.nutritionFailure is NetworkFailure)
              ConnectionErrorView(
                onRetry: onRetry ?? () => context.read<StreakCubit>().refresh(),
                compact: true,
              ),
            if (data.nutritionSummary != null)
              StreakRow(
                title: 'Nutrition Streak',
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFF5ED1A0),
                currentStreak: data.nutritionSummary!.currentStreak,
                lastDate: data.nutritionSummary!.to,
                statusesByDate: {
                  for (final day in data.nutritionDays) day.date: day.status,
                },
              )
            else if (data.nutritionFailure is! NetworkFailure)
              Text(data.nutritionError ?? 'Nutrition streak unavailable'),
            SizedBox(height: 10.h),
            if (data.workoutFailure is NetworkFailure)
              ConnectionErrorView(
                onRetry: onRetry ?? () => context.read<StreakCubit>().refresh(),
                compact: true,
              ),
            if (data.workoutSummary != null)
              StreakRow(
                title: 'Workout Streak',
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFB76CFF),
                currentStreak: data.workoutSummary!.currentStreak,
                lastDate: data.workoutSummary!.to,
                showLastDate: false,
                statusesByDate: {
                  for (final day in data.workoutDays) day.date: day.status,
                },
              )
            else if (data.workoutFailure is! NetworkFailure)
              Text(data.workoutError ?? 'Workout streak unavailable'),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Your Streak',
          style: AppTextStyles.medium16(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
