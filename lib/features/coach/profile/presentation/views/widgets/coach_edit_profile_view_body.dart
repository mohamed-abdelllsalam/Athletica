import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/profile/presentation/views/coach_profile_photo_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachEditProfileViewBody extends StatefulWidget {
  const CoachEditProfileViewBody({super.key});

  @override
  State<CoachEditProfileViewBody> createState() =>
      _CoachEditProfileViewBodyState();
}

class _CoachEditProfileViewBodyState extends State<CoachEditProfileViewBody> {
  // Initial (saved) values used to detect changes
  static const String _initialName = 'Mohamed Ahmed';
  static const String _initialEmail = 'mohamed12@gmail.com';
  static const String _initialPhone = '1234567890';
  static const String _initialBio =
      'Passionate strength coach with 3+ years helping clients reach their fitness goals. Focused on motivation, discipline, and real results\nhelping busy people get strong, fit, and confident through customized plans .';

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _initialName);
    _emailController = TextEditingController(text: _initialEmail);
    _phoneController = TextEditingController(text: _initialPhone);
    _bioController = TextEditingController(text: _initialBio);

    for (final c in [
      _nameController,
      _emailController,
      _phoneController,
      _bioController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    final changed = _nameController.text != _initialName ||
        _emailController.text != _initialEmail ||
        _phoneController.text != _initialPhone ||
        _bioController.text != _initialBio;
    if (changed != _hasChanges) setState(() => _hasChanges = changed);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
            SizedBox(height: 8.h),
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),
                    _buildAvatar(context),
                    SizedBox(height: 28.h),
                    _buildTextField(
                      context,
                      label: 'Name',
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                    ),
                    SizedBox(height: 18.h),
                    _buildTextField(
                      context,
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 18.h),
                    _buildPhoneField(context),
                    SizedBox(height: 18.h),
                    _buildTextField(
                      context,
                      label: 'Bio',
                      controller: _bioController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                    ),
                    SizedBox(height: 18.h),
                    _buildCertificatesRow(context),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
          Expanded(
            child: Text(
              'Edit Profile',
              textAlign: TextAlign.center,
              style: AppTextStyles.bold20(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
          // Placeholder to balance the back button
          SizedBox(width: 20.sp),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () =>
            Navigator.pushNamed(context, CoachProfilePhotoView.routeName),
        child: CircleAvatar(
          radius: 46.r,
          backgroundColor: AppColors.cardBackground,
          child: Icon(
            Icons.person,
            size: 46.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTextStyles.medium14(
        context,
      ).copyWith(color: AppColors.textPrimary),
      decoration: _fieldDecoration(context, label: label),
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    final textStyle = AppTextStyles.medium14(
      context,
    ).copyWith(color: AppColors.textPrimary);

    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: textStyle,
      decoration: _fieldDecoration(context, label: 'Phone').copyWith(
        prefix: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('+20', style: textStyle),
            SizedBox(width: 8.w),
            Container(
              width: 1,
              height: 18.h,
              color: AppColors.textTertiary,
            ),
            SizedBox(width: 8.w),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatesRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Certificates',
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.add_rounded,
              color: AppColors.textPrimary,
              size: 18.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      color: AppColors.primaryAppColor,
      child: SizedBox(
        height: 52.h,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _hasChanges ? AppColors.primaryBlue : AppColors.surfaceDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            elevation: 0,
          ),
          child: Text(
            'Save Change',
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(BuildContext context, {required String label}) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.medium13(
        context,
      ).copyWith(color: AppColors.textSecondary),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      floatingLabelStyle: AppTextStyles.medium13(
        context,
      ).copyWith(color: AppColors.primaryBlue),
      filled: false,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.textTertiary, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 16.h,
      ),
    );
  }
}
