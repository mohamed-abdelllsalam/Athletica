import 'package:athletica/core/widgets/connection_error_view.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';
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
  late final TextEditingController _usernameController;
  late final TextEditingController _genderController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _goalController;
  late final TextEditingController _phoneNumberController;
  String? _selectedLocation;

  bool _hasChanges = false;
  bool _retryingLoad = false;
  String _initialUsername = '';
  String _initialGender = '';
  String _initialHeight = '';
  String _initialWeight = '';
  String _initialGoal = '';
  String _initialPhoneNumber = '';
  String _initialLocation = '';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _genderController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _goalController = TextEditingController();
    _phoneNumberController = TextEditingController();

    _initializeFromProfile();

    for (final c in [
      _usernameController,
      _genderController,
      _heightController,
      _weightController,
      _goalController,
      _phoneNumberController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  void _initializeFromProfile() {
    final state = context.read<ProfileCubit>().state;
    final profile = switch (state) {
      ProfileLoaded(:final profile) => profile,
      ProfileError(:final profile) => profile,
      _ => null,
    };
    if (profile != null) {
      _initialUsername = profile.name;
      _initialGender = profile.gender ?? '';
      _initialHeight = profile.height?.toString() ?? '';
      _initialWeight = profile.weight?.toString() ?? '';
      _initialGoal = profile.goal ?? '';
      _initialPhoneNumber = profile.phoneNumber ?? '';
      _initialLocation = profile.location ?? '';
      _usernameController.text = _initialUsername;
      _genderController.text = _initialGender;
      _heightController.text = _initialHeight;
      _weightController.text = _initialWeight;
      _goalController.text = _initialGoal;
      _phoneNumberController.text = _initialPhoneNumber;
      _selectedLocation = _initialLocation.isEmpty ? null : _initialLocation;
      _onFieldChanged();
    }
  }

  void _onFieldChanged() {
    final changed =
        _usernameController.text.trim() != _initialUsername.trim() ||
        _genderController.text != _initialGender ||
        _heightController.text != _initialHeight ||
        _weightController.text != _initialWeight ||
        _goalController.text != _initialGoal ||
        _phoneNumberController.text.trim() != _initialPhoneNumber.trim() ||
        (_selectedLocation ?? '') != _initialLocation;
    if (changed != _hasChanges) setState(() => _hasChanges = changed);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onFieldChanged);
    _usernameController.dispose();
    _genderController.removeListener(_onFieldChanged);
    _genderController.dispose();
    _heightController.removeListener(_onFieldChanged);
    _heightController.dispose();
    _weightController.removeListener(_onFieldChanged);
    _weightController.dispose();
    _goalController.removeListener(_onFieldChanged);
    _goalController.dispose();
    _phoneNumberController.removeListener(_onFieldChanged);
    _phoneNumberController.dispose();
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
                        label: 'Username :',
                        hint: 'Type your Username ..!',
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 16.h),
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
                      SizedBox(height: 16.h),
                      _EditField(
                        label: 'Phone Number :',
                        hint: '+201234567890',
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16.h),
                      _buildLocationDropdown(),
                      SizedBox(height: 40.h),
                      BlocConsumer<ProfileCubit, ProfileState>(
                        listener: (context, state) {
                          if (state is ProfileLoaded) {
                            if (_retryingLoad) {
                              _retryingLoad = false;
                              if (!_hasChanges) _initializeFromProfile();
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          } else if (state is ProfileError) {
                            _retryingLoad = false;
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
                          return Column(
                            children: [
                              if (state is ProfileError &&
                                  state.isConnectionError)
                                ConnectionErrorView(
                                  compact: true,
                                  onRetry: () {
                                    _retryingLoad = true;
                                    context.read<ProfileCubit>().loadProfile(
                                      forceRefresh: true,
                                    );
                                  },
                                ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (_hasChanges && !isUpdating)
                                      ? _saveProfile
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _hasChanges
                                        ? AppColors.buttonColor
                                        : AppColors.surfaceDark,
                                    foregroundColor: AppColors.textPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14.h,
                                    ),
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
                                          style:
                                              AppTextStyles.semiBold15(
                                                context,
                                              ).copyWith(
                                                color: AppColors.textPrimary,
                                              ),
                                        ),
                                ),
                              ),
                            ],
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

  Widget _buildLocationDropdown() {
    // Keep showing a legacy/custom value even if it is not in the fixed list.
    final items = [
      ...egyptLocations,
      if (_initialLocation.isNotEmpty &&
          !egyptLocations.contains(_initialLocation))
        _initialLocation,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Location :',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            const Spacer(),
            if (_selectedLocation != null)
              GestureDetector(
                onTap: () {
                  setState(() => _selectedLocation = null);
                  _onFieldChanged();
                },
                child: Text(
                  'Clear',
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.primaryBlue),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          initialValue: _selectedLocation,
          isExpanded: true,
          dropdownColor: AppColors.cardBackground,
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Select your Location ..!',
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
          items: items.map((location) {
            return DropdownMenuItem(
              value: location,
              child: Text(location, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedLocation = value);
            _onFieldChanged();
          },
        ),
      ],
    );
  }

  void _saveProfile() {
    // Send only the fields that actually changed. Untouched fields are
    // omitted so empty values can never fail backend validation, and an
    // explicitly cleared phone/location is sent as "" (stored as null).
    final username = _usernameController.text.trim();
    final gender = _genderController.text.trim();
    final goal = _goalController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();

    final newUsername =
        username != _initialUsername.trim() && username.isNotEmpty
        ? username
        : null;
    final newGender =
        _genderController.text != _initialGender && gender.isNotEmpty
        ? _genderController.text
        : null;
    final newHeight = _heightController.text != _initialHeight
        ? double.tryParse(_heightController.text.trim())
        : null;
    final newWeight = _weightController.text != _initialWeight
        ? double.tryParse(_weightController.text.trim())
        : null;
    final newGoal = _goalController.text != _initialGoal && goal.isNotEmpty
        ? _goalController.text
        : null;
    final newPhoneNumber = phoneNumber != _initialPhoneNumber.trim()
        ? phoneNumber
        : null;
    final newLocation = (_selectedLocation ?? '') != _initialLocation
        ? (_selectedLocation ?? '')
        : null;

    // Nothing effective to send (e.g. whitespace-only edit): do not call
    // the API, the backend would answer 400 no_fields_to_update.
    if (newUsername == null &&
        newGender == null &&
        newHeight == null &&
        newWeight == null &&
        newGoal == null &&
        newPhoneNumber == null &&
        newLocation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No changes to save.')));
      return;
    }

    context.read<ProfileCubit>().updateProfile(
      username: newUsername,
      gender: newGender,
      height: newHeight,
      weight: newWeight,
      goal: newGoal,
      phoneNumber: newPhoneNumber,
      location: newLocation,
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
