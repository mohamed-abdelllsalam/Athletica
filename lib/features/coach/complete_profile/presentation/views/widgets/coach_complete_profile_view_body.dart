import 'coach_complete_profile_sections.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_add_certificate_view.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/widgets/coach_dashed_upload_box.dart';
// import 'package:athletica/features/coach/complete_profile/presentation/views/coach_subscription_view.dart';
// import 'package:athletica/features/coach/complete_profile/presentation/views/coach_upload_video_view.dart';
import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/features/coach/home/presentation/views/coach_home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachCompleteProfileViewBody extends StatefulWidget {
  const CoachCompleteProfileViewBody({super.key});

  @override
  State<CoachCompleteProfileViewBody> createState() =>
      _CoachCompleteProfileViewBodyState();
}

class _CoachCompleteProfileViewBodyState
    extends State<CoachCompleteProfileViewBody> {
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
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
                    SizedBox(height: 20.h),
                    CoachProfileBioField(controller: _bioController),
                    SizedBox(height: 28.h),
                    CoachProfileCompletionHeading(
                      title: 'Certificates',
                      subtitle:
                          'Add certificate details to highlight your expertise to potential clients',
                    ),
                    SizedBox(height: 12.h),
                    CoachDashedUploadBox(
                      title: 'Upload your certificates',
                      subtitle:
                          'Upload your certificates to verify your expertise.',
                      onUploadTap: () => Navigator.of(
                        context,
                      ).pushNamed(CoachAddCertificateView.routeName),
                      showSkip: true,
                      onSkipTap: () {},
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
            CoachProfileCompletionActions(
              onContinue: () {},
              onSkip: () async {
                await TokenStorageService.instance.saveProfileComplete();
                if (!context.mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  CoachHomeView.routeName,
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
