import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/chat/presentation/views/chat_view.dart';
import 'package:athletica/features/client_coach/presentation/views/client_coach_view.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_state.dart';
import 'package:athletica/features/profile/presentation/views/profile_view.dart';
import 'package:athletica/features/settings/presentation/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          BlocBuilder<ProfileCubit, ProfileState>(
            buildWhen: (prev, curr) =>
                curr is ProfileLoaded || curr is ProfileLoading,
            builder: (context, state) {
              final imageUrl =
                  state is ProfileLoaded
                      ? state.profile.client.profileImage
                      : null;
              final name =
                  state is ProfileLoaded ? state.profile.client.name : '...';

              return Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, ProfileView.routeName),
                    child: CircleAvatar(
                      radius: 22.r,
                      backgroundColor: AppColors.cardBackgroundLight,
                      backgroundImage:
                          imageUrl != null ? NetworkImage(imageUrl) : null,
                      child: imageUrl == null
                          ? Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                              size: 24.sp,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    name,
                    style: AppTextStyles.semiBold15(context)
                        .copyWith(color: AppColors.textPrimary),
                  ),
                ],
              );
            },
          ),
          const Spacer(),
          _buildIconButton(
            icon: Icons.fitness_center,
            badgeCount: 0,
            onTap: () {
              Navigator.pushNamed(context, ClientCoachView.routeName);
            },
          ),
          SizedBox(width: 8.w),
          _buildIconButton(
            icon: Icons.mail_outline_rounded,
            badgeCount: 0,
            onTap: () {
              Navigator.pushNamed(context, ChatView.routeName);
            },
          ),
          SizedBox(width: 8.w),
          _buildIconButton(
            icon: Icons.notifications_none_rounded,
            badgeCount: 2,
          ),
          SizedBox(width: 8.w),
          _buildIconButton(
            icon: Icons.settings_outlined,
            badgeCount: 0,
            onTap: () {
              Navigator.pushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required int badgeCount,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 20.sp),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(
                  color: AppColors.notificationBadge,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
