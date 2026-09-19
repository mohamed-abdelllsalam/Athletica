import 'coach_video_upload_states.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/complete_profile/presentation/cubits/upload_video_cubit.dart';
import 'package:athletica/features/coach/complete_profile/presentation/cubits/upload_video_state.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/widgets/coach_dashed_upload_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachUploadVideoViewBody extends StatelessWidget {
  const CoachUploadVideoViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Upload Video',
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload a video',
                style: AppTextStyles.bold20(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
              SizedBox(height: 6.h),
              Text(
                'This video will be shown to potential clients on your profile',
                style: AppTextStyles.regular13(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: 20.h),
              BlocBuilder<UploadVideoCubit, UploadVideoState>(
                builder: (context, state) {
                  return switch (state) {
                    UploadVideoInitial() => CoachDashedUploadBox(
                      title: 'Upload your video',
                      subtitle:
                          'Upload a video to introduce yourself to potential clients.',
                      onUploadTap: () =>
                          context.read<UploadVideoCubit>().pickAndUploadVideo(),
                    ),
                    UploadVideoLoading() => const CoachVideoUploadLoading(),
                    UploadVideoSuccess() => CoachVideoUploadSuccess(
                      videoPath: state.videoPath,
                      onReplace: () =>
                          context.read<UploadVideoCubit>().replaceVideo(),
                    ),
                    UploadVideoFailure() => CoachVideoUploadError(
                      onRetry: () => context.read<UploadVideoCubit>().retry(),
                    ),
                  };
                },
              ),
              const Spacer(),
              BlocBuilder<UploadVideoCubit, UploadVideoState>(
                builder: (context, state) {
                  final isSuccess = state is UploadVideoSuccess;
                  return SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: isSuccess
                          ? () => Navigator.of(context).pop()
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        disabledBackgroundColor: AppColors.surfaceDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save & Continue',
                        style: AppTextStyles.semiBold15(context).copyWith(
                          color: isSuccess
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
