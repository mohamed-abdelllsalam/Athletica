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
                    UploadVideoLoading() => const _VideoLoadingState(),
                    UploadVideoSuccess() => _VideoSuccessState(
                      videoPath: state.videoPath,
                      onReplace: () =>
                          context.read<UploadVideoCubit>().replaceVideo(),
                    ),
                    UploadVideoFailure() => _VideoErrorState(
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

class _VideoLoadingState extends StatelessWidget {
  const _VideoLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
    );
  }
}

class _VideoErrorState extends StatelessWidget {
  const _VideoErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textSecondary, width: 1.5),
              ),
              child: Icon(
                Icons.priority_high_rounded,
                color: AppColors.textSecondary,
                size: 22.r,
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Try again',
                style: AppTextStyles.medium13(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.close, color: Colors.redAccent, size: 18),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Upload failed. Please try again or check your internet connection',
                style: AppTextStyles.regular13(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VideoSuccessState extends StatelessWidget {
  const _VideoSuccessState({required this.videoPath, required this.onReplace});

  final String videoPath;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Container(
                width: double.infinity,
                height: 200.h,
                color: AppColors.cardBackground,
                child: const Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.textPrimary,
                    size: 48,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: onReplace,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Replace Video',
                style: AppTextStyles.medium13(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
