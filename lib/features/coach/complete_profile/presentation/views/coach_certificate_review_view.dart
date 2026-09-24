import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/pdf_opener.dart';
import 'package:athletica/features/achievements/domain/entities/coach_achievement.dart';
import 'package:athletica/features/achievements/presentation/views/widgets/achievement_list.dart';
import 'package:athletica/features/complete_profile/presentation/cubits/complete_profile_cubit.dart';
import 'package:athletica/features/complete_profile/presentation/cubits/complete_profile_state.dart';
import 'package:athletica/features/coach/home/presentation/views/coach_home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachCertificateReviewView extends StatelessWidget {
  const CoachCertificateReviewView({super.key, required this.certificates});

  static const String routeName = 'coach-certificate-review';

  final List<CoachAchievement> certificates;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CompleteProfileCubit>(),
      child: _CoachCertificateReviewBody(certificates: certificates),
    );
  }
}

class _CoachCertificateReviewBody extends StatelessWidget {
  const _CoachCertificateReviewBody({required this.certificates});

  final List<CoachAchievement> certificates;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompleteProfileCubit, CompleteProfileState>(
      listener: (context, state) async {
        if (state is CompleteProfileError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          return;
        }
        if (state is! CompleteProfileSuccess) return;

        await TokenStorageService.instance.saveProfileComplete();
        // This flag survives logout/login via TokenStorageService.clearAll().
        await TokenStorageService.instance
            .setCoachCompleteProfilePromptDismissed();
        if (!context.mounted) return;

        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text(
              'Profile completed',
              style: AppTextStyles.semiBold15(
                dialogContext,
              ).copyWith(color: AppColors.textPrimary),
            ),
            content: Text(
              'Your profile and certificates were completed successfully.',
              style: AppTextStyles.medium14(
                dialogContext,
              ).copyWith(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Okay'),
              ),
            ],
          ),
        );
        if (!context.mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(CoachHomeView.routeName, (_) => false);
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryAppColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Review certificates',
            style: AppTextStyles.bold20(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: AchievementList(
                    achievements: certificates,
                    onOpen: (achievement) => openPdfFromContext(
                      context,
                      achievement.fileUrl,
                      title: achievement.title,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
                child: BlocBuilder<CompleteProfileCubit, CompleteProfileState>(
                  builder: (context, state) {
                    final isLoading = state is CompleteProfileLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () =>
                                  context.read<CompleteProfileCubit>().submit(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          disabledBackgroundColor: AppColors.buttonColor
                              .withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Okay',
                                style: AppTextStyles.semiBold15(
                                  context,
                                ).copyWith(color: AppColors.textPrimary),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
