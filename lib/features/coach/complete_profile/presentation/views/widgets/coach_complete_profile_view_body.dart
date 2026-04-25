import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_add_certificate_view.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_subscription_view.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_upload_video_view.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/widgets/coach_dashed_upload_box.dart';
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
                    _BioTextArea(controller: _bioController),
                    SizedBox(height: 28.h),
                    _SectionHeader(
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
                    SizedBox(height: 28.h),
                    _SectionHeader(
                      title: 'Introduction Video',
                      subtitle:
                          'Upload a short video to introduce yourself, share your coaching style, and tell people why they should trust you.',
                    ),
                    SizedBox(height: 12.h),
                    CoachDashedUploadBox(
                      title: 'Upload your video',
                      subtitle:
                          'Upload a video to introduce yourself to potential clients.',
                      onUploadTap: () => Navigator.of(
                        context,
                      ).pushNamed(CoachUploadVideoView.routeName),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
            _BottomBar(
              onContinue: () => Navigator.of(
                context,
              ).pushNamed(CoachSubscriptionView.routeName),
            ),
          ],
        ),
      ),
    );
  }
}

class _BioTextArea extends StatelessWidget {
  const _BioTextArea({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 5,
      style: AppTextStyles.medium14(
        context,
      ).copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText:
            'Hook your future clients, show them what makes you different.',
        hintStyle: AppTextStyles.regular13(
          context,
        ).copyWith(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: AppTextStyles.regular13(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Dot(active: true),
              SizedBox(width: 6.w),
              _Dot(active: false),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Continue',
                style: AppTextStyles.semiBold15(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 20.w : 8.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: active ? AppColors.primaryBlue : AppColors.textTertiary,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
