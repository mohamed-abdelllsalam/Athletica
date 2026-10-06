import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/widgets/connection_error_view.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/pdf_opener.dart';
import 'package:athletica/features/achievements/domain/entities/coach_achievement.dart';
import 'package:athletica/features/achievements/presentation/cubits/coach_achievements_cubit.dart';
import 'package:athletica/features/achievements/presentation/cubits/coach_achievements_state.dart';
import 'package:athletica/features/achievements/presentation/views/widgets/achievement_list.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_add_certificate_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachAchievementsSection extends StatelessWidget {
  const CoachAchievementsSection({super.key, this.canDelete = true});

  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CoachAchievementsCubit, CoachAchievementsState>(
      listenWhen: (previous, current) =>
          current is CoachAchievementsDeleteSuccess ||
          current is CoachAchievementsError,
      listener: (context, state) {
        final message = switch (state) {
          CoachAchievementsDeleteSuccess(:final title) =>
            '$title deleted successfully.',
          CoachAchievementsError(:final message) => message,
          _ => null,
        };
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      child: BlocBuilder<CoachAchievementsCubit, CoachAchievementsState>(
        builder: (context, state) {
          final data = switch (state) {
            CoachAchievementsLoaded(:final achievements) => achievements,
            CoachAchievementsDeleting(:final achievements) => achievements,
            CoachAchievementsDeleteSuccess(:final achievements) => achievements,
            CoachAchievementsError(:final previous?) => previous,
            _ => null,
          };
          final deletingId = state is CoachAchievementsDeleting
              ? state.achievementId
              : null;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Certificates',
                        style: AppTextStyles.bold20(
                          context,
                        ).copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    if (canDelete)
                      SizedBox(
                        height: 36.h,
                        child: ElevatedButton.icon(
                          onPressed: () => _openAddCertificate(context),
                          icon: Icon(
                            Icons.add,
                            size: 18.sp,
                            color: AppColors.textPrimary,
                          ),
                          label: Text(
                            'Add',
                            style: AppTextStyles.semiBold14(
                              context,
                            ).copyWith(color: AppColors.textPrimary),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 14.w),
                            elevation: 0,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12.h),
                if (state is CoachAchievementsError && state.connectionError)
                  ConnectionErrorView(
                    compact: data != null,
                    onRetry: () => context.read<CoachAchievementsCubit>().load(
                      forceRefresh: true,
                    ),
                  ),
                if (state is CoachAchievementsInitial ||
                    state is CoachAchievementsLoading)
                  const LinearProgressIndicator(color: AppColors.primaryBlue)
                else if (data != null)
                  AchievementList(
                    achievements: data,
                    onOpen: (achievement) => openPdfFromContext(
                      context,
                      achievement.fileUrl,
                      title: achievement.title,
                    ),
                    onDelete: canDelete
                        ? (achievement) => _confirmDelete(context, achievement)
                        : null,
                    deletingId: deletingId,
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state is CoachAchievementsError
                            ? state.message
                            : 'Unable to load certificates.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.medium14(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: () => context
                            .read<CoachAchievementsCubit>()
                            .load(forceRefresh: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openAddCertificate(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CoachAddCertificateView()));
    if (!context.mounted) return;
    await context.read<CoachAchievementsCubit>().load(forceRefresh: true);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CoachAchievement achievement,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Delete certificate?',
          style: AppTextStyles.semiBold15(
            dialogContext,
          ).copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'This certificate will be permanently removed.',
          style: AppTextStyles.medium14(
            dialogContext,
          ).copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<CoachAchievementsCubit>().delete(achievement.id);
    }
  }
}
