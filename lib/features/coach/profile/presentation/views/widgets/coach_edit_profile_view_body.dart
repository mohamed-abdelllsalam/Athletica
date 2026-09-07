import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/profile/presentation/cubits/coach_profile_cubit.dart';
import 'package:athletica/features/coach/profile/presentation/cubits/coach_profile_state.dart';
import 'package:athletica/features/coach/profile/presentation/views/coach_profile_photo_view.dart';
import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachEditProfileViewBody extends StatefulWidget {
  const CoachEditProfileViewBody({super.key});

  @override
  State<CoachEditProfileViewBody> createState() =>
      _CoachEditProfileViewBodyState();
}

class _CoachEditProfileViewBodyState extends State<CoachEditProfileViewBody> {
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _phoneNumberController;
  Specialization? _selectedSpecialization;
  String? _selectedLocation;

  bool _hasChanges = false;
  String _initialUsername = '';
  String _initialBio = '';
  String? _initialSpecializationKey;
  String _initialPhoneNumber = '';
  String _initialLocation = '';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
    _phoneNumberController = TextEditingController();

    _initializeFromProfile();

    for (final c in [
      _usernameController,
      _bioController,
      _phoneNumberController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  void _initializeFromProfile() {
    final state = context.read<CoachProfileCubit>().state;
    if (state is CoachProfileLoaded) {
      final profile = state.profile;
      _initialUsername = profile.name;
      _initialBio = profile.bio;
      _initialSpecializationKey = profile.specialization;
      _initialPhoneNumber = profile.phoneNumber ?? '';
      _initialLocation = profile.location ?? '';
      _usernameController.text = _initialUsername;
      _bioController.text = _initialBio;
      _selectedSpecialization =
          Specialization.fromKey(_initialSpecializationKey);
      _phoneNumberController.text = _initialPhoneNumber;
      _selectedLocation =
          _initialLocation.isEmpty ? null : _initialLocation;
      _onFieldChanged();
    }
  }

  void _onFieldChanged() {
    final specChanged =
        _selectedSpecialization?.name != _initialSpecializationKey;
    final changed = _usernameController.text.trim() !=
            _initialUsername.trim() ||
        _bioController.text != _initialBio ||
        specChanged ||
        _phoneNumberController.text.trim() != _initialPhoneNumber.trim() ||
        (_selectedLocation ?? '') != _initialLocation;
    if (changed != _hasChanges) setState(() => _hasChanges = changed);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CoachProfileCubit, CoachProfileState>(
      listener: (context, state) {
        if (state is CoachProfileLoaded) {
          _initializeFromProfile();
        }
      },
      child: Scaffold(
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
                        label: 'Username',
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 18.h),
                      _buildSpecializationDropdown(context),
                      SizedBox(height: 18.h),
                      _buildTextField(
                        context,
                        label: 'Bio',
                        controller: _bioController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                      ),
                      SizedBox(height: 18.h),
                      _buildTextField(
                        context,
                        label: 'Phone Number',
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 18.h),
                      _buildLocationDropdown(context),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
              _buildSaveButton(context),
            ],
          ),
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
          SizedBox(width: 20.sp),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final profileState = context.watch<CoachProfileCubit>().state;
    final profileImage = switch (profileState) {
      CoachProfileLoaded(:final profile) => profile.profileImage,
      CoachProfileUpdating(:final profile) => profile.profileImage,
      CoachProfileImageUploading(:final profile) => profile.profileImage,
      CoachProfileImageUploaded(:final profile) => profile.profileImage,
      CoachProfileImageDeleted(:final profile) => profile.profileImage,
      _ => null,
    };

    return Center(
      child: GestureDetector(
        onTap: () {
          final cubit = context.read<CoachProfileCubit>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: const CoachProfilePhotoView(),
              ),
            ),
          );
        },
        child: CircleAvatar(
          radius: 46.r,
          backgroundColor: AppColors.cardBackground,
          backgroundImage: profileImage != null && profileImage.isNotEmpty
              ? NetworkImage(profileImage)
              : null,
          child: profileImage == null || profileImage.isEmpty
              ? Icon(
                  Icons.person,
                  size: 46.sp,
                  color: AppColors.textSecondary,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSpecializationDropdown(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specialization',
          style: AppTextStyles.medium13(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<Specialization>(
          initialValue: _selectedSpecialization,
          isExpanded: true,
          dropdownColor: AppColors.cardBackground,
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: false,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide:
                  BorderSide(color: AppColors.textTertiary, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide:
                  BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
          items: Specialization.values.map((s) {
            return DropdownMenuItem(
              value: s,
              child: Text(s.label(locale)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedSpecialization = value);
            _onFieldChanged();
          },
        ),
      ],
    );
  }

  Widget _buildLocationDropdown(BuildContext context) {
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
              'Location',
              style: AppTextStyles.medium13(
                context,
              ).copyWith(color: AppColors.textSecondary),
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
                  style: AppTextStyles.medium13(
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
            hintText: 'Select your Location',
            hintStyle: AppTextStyles.medium13(
              context,
            ).copyWith(color: AppColors.textSecondary),
            filled: false,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide:
                  BorderSide(color: AppColors.textTertiary, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide:
                  BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
          items: items.map((location) {
            return DropdownMenuItem(
              value: location,
              child: Text(
                location,
                overflow: TextOverflow.ellipsis,
              ),
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
      decoration: InputDecoration(
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
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return BlocConsumer<CoachProfileCubit, CoachProfileState>(
      listener: (context, state) {
        if (state is CoachProfileLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is CoachProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isUpdating = state is CoachProfileUpdating;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          color: AppColors.primaryAppColor,
          child: SizedBox(
            height: 52.h,
            child: ElevatedButton(
              onPressed: (_hasChanges && !isUpdating) ? _saveProfile : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _hasChanges ? AppColors.primaryBlue : AppColors.surfaceDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
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
                      'Save Change',
                      style: AppTextStyles.semiBold15(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
            ),
          ),
        );
      },
    );
  }

  void _saveProfile() {
    // Send only the fields that actually changed. Untouched fields are
    // omitted so empty values can never fail backend validation, and an
    // explicitly cleared phone/location is sent as "" (stored as null).
    final username = _usernameController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();

    final newUsername =
        username != _initialUsername.trim() && username.isNotEmpty
            ? username
            : null;
    final newBio =
        _bioController.text != _initialBio ? _bioController.text : null;
    final newSpecialization =
        _selectedSpecialization?.name != _initialSpecializationKey
            ? _selectedSpecialization?.name
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
        newBio == null &&
        newSpecialization == null &&
        newPhoneNumber == null &&
        newLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes to save.')),
      );
      return;
    }

    context.read<CoachProfileCubit>().updateProfile(
          username: newUsername,
          bio: newBio,
          specialization: newSpecialization,
          phoneNumber: newPhoneNumber,
          location: newLocation,
        );
  }
}
