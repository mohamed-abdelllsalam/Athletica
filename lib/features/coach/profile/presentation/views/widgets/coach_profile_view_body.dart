import 'package:athletica/core/widgets/connection_error_view.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/achievements/presentation/views/widgets/coach_achievements_section.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_state.dart';
import 'package:athletica/features/coach/profile/presentation/cubits/coach_profile_cubit.dart';
import 'package:athletica/features/coach/profile/presentation/cubits/coach_profile_state.dart';
import 'package:athletica/features/coach/profile/presentation/views/coach_edit_profile_view.dart';
import 'package:athletica/features/on_boarding/presentation/views/on_boarding_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'coach_profile_header.dart';
import 'coach_profile_personal_info.dart';

class CoachProfileViewBody extends StatefulWidget {
  const CoachProfileViewBody({super.key});

  @override
  State<CoachProfileViewBody> createState() => _CoachProfileViewBodyState();
}

class _CoachProfileViewBodyState extends State<CoachProfileViewBody> {
  @override
  void initState() {
    super.initState();
    context.read<CoachProfileCubit>().loadProfile();
  }

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
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, authState) {
        final isLoggingOut = authState is AuthLoading;
        return BlocBuilder<CoachProfileCubit, CoachProfileState>(
          builder: (context, profileState) {
            return _ProfileBody(
              profileState: profileState,
              isLoggingOut: isLoggingOut,
            );
          },
        );
      },
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profileState, required this.isLoggingOut});

  final CoachProfileState profileState;
  final bool isLoggingOut;

  @override
  Widget build(BuildContext context) {
    final profile = switch (profileState) {
      CoachProfileLoaded(:final profile) => profile,
      CoachProfileUpdating(:final profile) => profile,
      CoachProfileImageUploading(:final profile) => profile,
      CoachProfileImageUploaded(:final profile) => profile,
      CoachProfileImageDeleted(:final profile) => profile,
      CoachProfileError(:final profile?) => profile,
      _ => null,
    };

    final connectionError =
        profileState is CoachProfileError &&
        (profileState as CoachProfileError).isConnectionError;
    if (profile == null &&
        !connectionError &&
        profileState is! CoachProfileLoading) {
      final message = profileState is CoachProfileError
          ? (profileState as CoachProfileError).message
          : 'Failed to load profile';
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () => context.read<CoachProfileCubit>().loadProfile(
                  forceRefresh: true,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          _buildAppBar(context),
          SizedBox(height: 20.h),
          if (profileState is CoachProfileLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            ),
          if (profileState case CoachProfileError(isConnectionError: true))
            ConnectionErrorView(
              compact: profile != null,
              onRetry: () => context.read<CoachProfileCubit>().loadProfile(
                forceRefresh: true,
              ),
            ),
          if (profile != null) ...[
            CoachProfileHeader(profile: profile),
            SizedBox(height: 24.h),
            CoachProfilePersonalInfo(profile: profile),
          ],
          const CoachAchievementsSection(),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 32.h),
            child: SizedBox(
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
                    : const Icon(Icons.logout_rounded, color: Colors.red),
                label: Text(
                  'Sign Out',
                  style: AppTextStyles.semiBold15(
                    context,
                  ).copyWith(color: Colors.red),
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
              style: AppTextStyles.bold20(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
          GestureDetector(
            onTap: () {
              final cubit = context.read<CoachProfileCubit>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: const CoachEditProfileView(),
                  ),
                ),
              );
            },
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
}
