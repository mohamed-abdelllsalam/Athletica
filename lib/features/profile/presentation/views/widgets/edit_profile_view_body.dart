import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfileViewBody extends StatefulWidget {
  const EditProfileViewBody({super.key});

  @override
  State<EditProfileViewBody> createState() => _EditProfileViewBodyState();
}

class _EditProfileViewBodyState extends State<EditProfileViewBody> {
  late final TextEditingController _genderController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _goalController;

  bool _hasChanges = false;
  String _initialGender = '';
  String _initialHeight = '';
  String _initialWeight = '';
  String _initialGoal = '';

  @override
  void initState() {
    super.initState();
    _genderController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _goalController = TextEditingController();

    _initializeFromProfile();

    for (final c in [
      _genderController,
      _heightController,
      _weightController,
      _goalController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  void _initializeFromProfile() {
    final state = context.read<ProfileCubit>().state;
    if (state is ProfileLoaded) {
      final profile = state.profile;
      _initialGender = profile.gender ?? '';
      _initialHeight = profile.height?.toString() ?? '';
      _initialWeight = profile.weight?.toString() ?? '';
      _initialGoal = profile.goal ?? '';
      _genderController.text = _initialGender;
      _heightController.text = _initialHeight;
      _weightController.text = _initialWeight;
      _goalController.text = _initialGoal;
    }
  }

  void _onFieldChanged() {
    final changed = _genderController.text != _initialGender ||
        _heightController.text != _initialHeight ||
        _weightController.text != _initialWeight ||
        _goalController.text != _initialGoal;
    if (changed != _hasChanges) setState(() => _hasChanges = changed);
  }

  @override
  void dispose() {
    _genderController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          _initializeFromProfile();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),
                      _EditField(
                        label: 'Gender :',
                        hint: 'Type your Gender ..!',
                        controller: _genderController,
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 16.h),
                      _EditField(
                        label: 'Height (cm) :',
                        hint: 'Type your Height ..!',
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16.h),
                      _EditField(
                        label: 'Weight (kg) :',
                        hint: 'Type your Weight ..!',
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16.h),
                      _EditField(
                        label: 'Goal',
                        hint: 'Type your Goal',
                        controller: _goalController,
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 40.h),
                      BlocConsumer<ProfileCubit, ProfileState>(
                        listener: (context, state) {
                          if (state is ProfileLoaded) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          } else if (state is ProfileError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          final isUpdating = state is ProfileUpdating;
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  (_hasChanges && !isUpdating) ? _saveProfile : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _hasChanges
                                    ? AppColors.buttonColor
                                    : AppColors.surfaceDark,
                                foregroundColor: AppColors.textPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                              ),
                              child: isUpdating
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Done',
                                      style: AppTextStyles.semiBold15(
                                        context,
                                      ).copyWith(color: AppColors.textPrimary),
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
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    context.read<ProfileCubit>().updateProfile(
          gender: _genderController.text,
          height: double.tryParse(_heightController.text),
          weight: double.tryParse(_weightController.text),
          goal: _goalController.text,
        );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
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
      ],
    );
  }
}
