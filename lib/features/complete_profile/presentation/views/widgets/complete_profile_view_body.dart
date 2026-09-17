import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/auth/domain/usecases/check_client_profile_completion_usecase.dart';
import 'package:athletica/features/complete_profile/presentation/views/widgets/photo_upload_area.dart';
import 'package:athletica/features/home/presentation/views/home_view.dart';
import 'package:athletica/features/info/presentation/views/info_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompleteProfileViewBody extends StatefulWidget {
  const CompleteProfileViewBody({super.key});

  @override
  State<CompleteProfileViewBody> createState() =>
      _CompleteProfileViewBodyState();
}

class _CompleteProfileViewBodyState extends State<CompleteProfileViewBody> {
  bool _resolving = false;

  /// Completion-aware Done: incomplete clients must answer the
  /// questionnaire first (fail-closed on error), complete ones go Home.
  Future<void> _onDone() async {
    if (_resolving) return;
    setState(() => _resolving = true);
    final result = await sl<CheckClientProfileCompletionUseCase>()();
    if (!mounted) return;
    final complete = switch (result) {
      ApiSuccess(:final data) => data,
      ApiError() => false,
    };
    setState(() => _resolving = false);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      complete ? HomeView.routeName : InfoView.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 32.h),
                Image.asset('assets/images/logo.png', height: 80.h),
                SizedBox(height: 8.h),
                Text(
                  'ATHLETICA',
                  style: AppTextStyles.extraBold30(
                    context,
                  ).copyWith(color: AppColors.primaryBlue, letterSpacing: 2),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Upload Your Photo',
                  style: AppTextStyles.bold24(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(height: 24.h),
                const PhotoUploadArea(),
                SizedBox(height: 24.h),
                SizedBox(
                  width: 160.w,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'Uploaded',
                      style: AppTextStyles.semiBold14(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Type Your Aage',
                    style: AppTextStyles.medium14(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Your Aage ...!',
                    hintStyle: AppTextStyles.medium14(
                      context,
                    ).copyWith(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _resolving ? null : _onDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: _resolving
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Done',
                            style: AppTextStyles.semiBold15(
                              context,
                            ).copyWith(color: AppColors.textPrimary),
                          ),
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
