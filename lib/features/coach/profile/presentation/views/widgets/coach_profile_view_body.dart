import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_state.dart';
import 'package:athletica/features/coach/profile/domain/entities/coach_profile_entity.dart';
import 'package:athletica/features/coach/profile/presentation/cubits/coach_profile_cubit.dart';
import 'package:athletica/features/coach/profile/presentation/cubits/coach_profile_state.dart';
import 'package:athletica/features/coach/profile/presentation/views/coach_edit_profile_view.dart';
import 'package:athletica/features/coach/profile/presentation/views/widgets/coach_certificate_item.dart';
import 'package:athletica/features/coach/profile/presentation/views/widgets/coach_profile_info_row.dart';
import 'package:athletica/features/on_boarding/presentation/views/on_boarding_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachProfileViewBody extends StatelessWidget {
  const CoachProfileViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            OnBoardingView.routeName,
            (_) => false,
          );
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, authState) {
        final isLoggingOut = authState is AuthLoading;
        return BlocBuilder<CoachProfileCubit, CoachProfileState>(
          builder: (context, profileState) {
            return switch (profileState) {
              CoachProfileLoading() || CoachProfileInitial() =>
                const Center(child: CircularProgressIndicator()),
              CoachProfileError(:final message) => _ErrorBody(
                  message: message,
                  onRetry: () =>
                      context.read<CoachProfileCubit>().loadProfile(forceRefresh: true),
                ),
              CoachProfileLoaded(:final profile) => _ProfileBody(
                  profile: profile,
                  isLoggingOut: isLoggingOut,
                ),
            };
          },
        );
      },
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile, required this.isLoggingOut});

  final CoachProfileEntity profile;
  final bool isLoggingOut;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          _buildAppBar(context),
          SizedBox(height: 20.h),
          _buildProfileHeader(context),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Info',
                  style: AppTextStyles.bold20(context)
                      .copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(height: 14.h),
                CoachProfileInfoRow(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: profile.user.email,
                ),
                SizedBox(height: 14.h),
                CoachProfileInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: profile.user.phone,
                ),
                SizedBox(height: 14.h),
                CoachProfileInfoRow(
                  icon: Icons.star_outline_rounded,
                  label: 'Rating',
                  value: profile.profile.rating == 0
                      ? 'No ratings yet'
                      : profile.profile.rating.toStringAsFixed(1),
                ),
                SizedBox(height: 14.h),
                CoachProfileInfoRow(
                  icon: Icons.fitness_center_outlined,
                  label: 'Experience',
                  value: profile.profile.yearsExperience == 0
                      ? 'Not specified'
                      : '${profile.profile.yearsExperience} years',
                ),
                SizedBox(height: 24.h),
                if (profile.profile.bio.isNotEmpty &&
                    profile.profile.bio != 'Pending') ...[
                  Text(
                    'Bio',
                    style: AppTextStyles.bold20(context)
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    profile.profile.bio,
                    style: AppTextStyles.regular13(context).copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
                if (profile.profile.certifications.isNotEmpty &&
                    profile.profile.certifications != 'Pending') ...[
                  Text(
                    'Certificates',
                    style: AppTextStyles.bold20(context)
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 14.h),
                  CoachCertificateItem(name: profile.profile.certifications),
                  SizedBox(height: 24.h),
                ],
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoggingOut
                        ? null
                        : () => context.read<AuthCubit>().logout(),
                    icon: isLoggingOut
                        ? SizedBox(
                            width: 18.sp,
                            height: 18.sp,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                          )
                        : const Icon(
                            Icons.logout_rounded,
                            color: Colors.red,
                          ),
                    label: Text(
                      'Sign Out',
                      style: AppTextStyles.semiBold15(context)
                          .copyWith(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              'Profile',
              textAlign: TextAlign.center,
              style: AppTextStyles.bold20(context)
                  .copyWith(color: AppColors.textPrimary),
            ),
          ),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, CoachEditProfileView.routeName),
            child: Icon(
              Icons.edit_outlined,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 48.r,
            backgroundColor: AppColors.cardBackground,
            backgroundImage: profile.user.profileImage != null
                ? NetworkImage(profile.user.profileImage!)
                : null,
            child: profile.user.profileImage == null
                ? Icon(Icons.person, size: 48.sp, color: AppColors.textSecondary)
                : null,
          ),
          SizedBox(height: 14.h),
          Text(
            profile.user.name,
            style: AppTextStyles.bold24(context)
                .copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 4.h),
          Text(
            'Fitness Coach',
            style: AppTextStyles.medium14(context)
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.regular13(context)
                  .copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
