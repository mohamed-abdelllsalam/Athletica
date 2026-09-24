import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/achievements/domain/entities/coach_achievement.dart';
import 'package:athletica/features/achievements/domain/usecases/upload_coach_achievement_usecase.dart';
import 'package:athletica/features/achievements/presentation/cubits/coach_achievements_cubit.dart';
import 'package:athletica/features/achievements/presentation/cubits/coach_achievements_state.dart';
import 'package:athletica/features/achievements/presentation/views/widgets/coach_achievements_section.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_add_certificate_view.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_certificate_review_view.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/widgets/coach_complete_profile_sections.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/widgets/coach_dashed_upload_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachCompleteProfileViewBody extends StatefulWidget {
  const CoachCompleteProfileViewBody({super.key});

  @override
  State<CoachCompleteProfileViewBody> createState() =>
      _CoachCompleteProfileViewBodyState();
}

class _CoachCompleteProfileViewBodyState
    extends State<CoachCompleteProfileViewBody> {
  bool _isContinuing = false;

  Future<void> _openCertificateForm() async {
    final result = await Navigator.of(
      context,
    ).pushNamed<CoachAchievement>(CoachAddCertificateView.routeName);
    if (!mounted || result == null) return;

    final cubit = context.read<CoachAchievementsCubit>();
    await cubit.load(forceRefresh: true);
    if (!mounted) return;
    final refreshState = cubit.state;
    final message = refreshState is CoachAchievementsError
        ? 'Certificate uploaded, but the list could not be refreshed.'
        : 'Certificate uploaded successfully.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _continue() async {
    if (_isContinuing) return;
    setState(() => _isContinuing = true);

    final cubit = context.read<CoachAchievementsCubit>();
    await cubit.load(forceRefresh: true);
    if (!mounted) return;

    final state = cubit.state;
    if (state is CoachAchievementsError) {
      if (!mounted) return;
      setState(() => _isContinuing = false);
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

    final certificates = switch (state) {
      CoachAchievementsLoaded(:final achievements) => achievements,
      _ => const <CoachAchievement>[],
    };

    if (certificates.isEmpty) {
      if (!mounted) return;
      setState(() => _isContinuing = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Upload at least one certificate to continue.'),
          ),
        );
      return;
    }

    if (!mounted) return;
    setState(() => _isContinuing = false);
    await Navigator.of(
      context,
    ).pushNamed(CoachCertificateReviewView.routeName, arguments: certificates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Complete your profile',
                        style: AppTextStyles.bold20(
                          context,
                        ).copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    SizedBox(height: 28.h),
                    CoachProfileCompletionHeading(
                      title: 'Certificates',
                      subtitle:
                          'Add certificate details to highlight your expertise to potential clients',
                    ),
                    SizedBox(height: 12.h),
                    BlocBuilder<CoachAchievementsCubit, CoachAchievementsState>(
                      builder: (context, state) {
                        final achievements = switch (state) {
                          CoachAchievementsLoaded(:final achievements) =>
                            achievements,
                          CoachAchievementsDeleteSuccess(
                            :final achievements,
                          ) =>
                            achievements,
                          CoachAchievementsDeleting(:final achievements) =>
                            achievements,
                          CoachAchievementsError(:final previous?) => previous,
                          _ => null,
                        };
                        final canUpload =
                            achievements == null ||
                            achievements.length <
                                UploadCoachAchievementUseCase.maxCertificates;
                        return CoachDashedUploadBox(
                          enabled: canUpload,
                          title: 'Upload your certificates',
                          subtitle: canUpload
                              ? 'Upload your certificates to verify your expertise.'
                              : 'You have reached the maximum of 50 certificates.',
                          onUploadTap: _openCertificateForm,
                        );
                      },
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'PDF only • Max 50 PDFs • Max 10 MB each',
                      style: AppTextStyles.regular13(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 24.h),
                    const CoachAchievementsSection(),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
            CoachProfileCompletionActions(onContinue: _continue),
          ],
        ),
      ),
    );
  }
}
