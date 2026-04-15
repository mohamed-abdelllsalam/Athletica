import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/settings/presentation/views/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsViewBody extends StatefulWidget {
  const SettingsViewBody({super.key});

  @override
  State<SettingsViewBody> createState() => _SettingsViewBodyState();
}

class _SettingsViewBodyState extends State<SettingsViewBody> {
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            _buildAppBar(context),
            SizedBox(height: 32.h),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      SettingsTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notification',
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          },
                          activeThumbColor: AppColors.textPrimary,
                          activeTrackColor: AppColors.primaryBlue,
                          inactiveThumbColor: AppColors.textSecondary,
                          inactiveTrackColor: AppColors.cardBackground,
                        ),
                      ),
                      const SettingsTile(
                        icon: Icons.star_rounded,
                        title: 'Rate App',
                      ),
                      const SettingsTile(
                        icon: Icons.share_rounded,
                        title: 'Share App',
                      ),
                      const SettingsTile(
                        icon: Icons.lock_rounded,
                        title: 'Privacy Policy',
                      ),
                      const SettingsTile(
                        icon: Icons.description_rounded,
                        title: 'Terms &Conditions',
                      ),
                      const SettingsTile(
                        icon: Icons.cookie_rounded,
                        title: 'Cookies policy',
                      ),
                      const SettingsTile(
                        icon: Icons.contact_mail_rounded,
                        title: 'Contact',
                      ),
                      const SettingsTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Feed Back',
                      ),
                      const SettingsTile(
                        icon: Icons.logout_rounded,
                        title: 'Log Out',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            'Setting',
            style: AppTextStyles.bold20(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
