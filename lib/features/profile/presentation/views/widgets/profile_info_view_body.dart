import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_info_cubit.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_info_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileInfoViewBody extends StatelessWidget {
  const ProfileInfoViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
                builder: (context, state) => switch (state) {
                  ProfileInfoInitial() || ProfileInfoLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ProfileInfoLoaded(:final answers) when answers.isEmpty =>
                    Center(
                      child: Text(
                        'No intake answers found.',
                        style: AppTextStyles.medium14(context)
                            .copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ProfileInfoLoaded(:final answers) => ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      itemCount: answers.length,
                      separatorBuilder: (_, _) => SizedBox(height: 24.h),
                      itemBuilder: (context, index) {
                        final answer = answers[index];
                        return _QuestionItem(
                          number: index + 1,
                          question: answer.question,
                          answer: answer.value,
                        );
                      },
                    ),
                  ProfileInfoError(:final message) => Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(
                          message,
                          style: AppTextStyles.medium14(context)
                              .copyWith(color: AppColors.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Information',
            style: AppTextStyles.bold20(context)
                .copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _QuestionItem extends StatelessWidget {
  const _QuestionItem({
    required this.number,
    required this.question,
    required this.answer,
  });

  final int number;
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Q$number',
          style: AppTextStyles.semiBold14(context)
              .copyWith(color: AppColors.primaryBlue),
        ),
        SizedBox(height: 4.h),
        Text(
          question,
          style: AppTextStyles.semiBold15(context)
              .copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  answer,
                  style: AppTextStyles.semiBold14(context)
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 26.r,
                height: 26.r,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  Icons.check,
                  color: AppColors.textPrimary,
                  size: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
