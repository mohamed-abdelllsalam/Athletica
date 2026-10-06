import 'package:athletica/core/widgets/connection_error_view.dart';
import 'coach_edit_profile_header.dart';
import 'coach_edit_profile_save_action.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/profile/presentation/cubits/coach_profile_cubit.dart';
import 'package:athletica/features/coach/profile/presentation/cubits/coach_profile_state.dart';
import 'package:athletica/features/coach/profile/presentation/views/coach_profile_photo_view.dart';
import 'package:athletica/features/coach/profile/presentation/views/widgets/coach_edit_profile_fields.dart';
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
  bool _retryingLoad = false;
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
    final profile = switch (state) {
      CoachProfileLoaded(:final profile) => profile,
      CoachProfileError(:final profile) => profile,
      _ => null,
    };
    if (profile != null) {
      _initialUsername = profile.name;
      _initialBio = profile.bio;
      _initialSpecializationKey = profile.specialization;
      _initialPhoneNumber = profile.phoneNumber ?? '';
      _initialLocation = profile.location ?? '';
      _usernameController.text = _initialUsername;
      _bioController.text = _initialBio;
      _selectedSpecialization = Specialization.fromKey(
        _initialSpecializationKey,
      );
      _phoneNumberController.text = _initialPhoneNumber;
      _selectedLocation = _initialLocation.isEmpty ? null : _initialLocation;
      _onFieldChanged();
    }
  }

  void _onFieldChanged() {
    final specChanged =
        _selectedSpecialization?.name != _initialSpecializationKey;
    final changed =
        _usernameController.text.trim() != _initialUsername.trim() ||
        _bioController.text != _initialBio ||
        specChanged ||
        _phoneNumberController.text.trim() != _initialPhoneNumber.trim() ||
        (_selectedLocation ?? '') != _initialLocation;
    if (changed != _hasChanges) setState(() => _hasChanges = changed);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onFieldChanged);
    _usernameController.dispose();
    _bioController.removeListener(_onFieldChanged);
    _bioController.dispose();
    _phoneNumberController.removeListener(_onFieldChanged);
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CoachProfileCubit, CoachProfileState>(
      listener: (context, state) {
        if (state is CoachProfileLoaded && !_hasChanges && !_retryingLoad) {
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
    return CoachEditProfileAppBar(onBack: () => Navigator.pop(context));
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

    return CoachEditProfileAvatar(
      profileImage: profileImage,
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
    );
  }

  Widget _buildSpecializationDropdown(BuildContext context) {
    return CoachSpecializationField(
      selected: _selectedSpecialization,
      onChanged: (value) {
        setState(() => _selectedSpecialization = value);
        _onFieldChanged();
      },
    );
  }

  Widget _buildLocationDropdown(BuildContext context) {
    final items = [
      ...egyptLocations,
      if (_initialLocation.isNotEmpty &&
          !egyptLocations.contains(_initialLocation))
        _initialLocation,
    ];
    return CoachLocationField(
      selected: _selectedLocation,
      items: items,
      onClear: () {
        setState(() => _selectedLocation = null);
        _onFieldChanged();
      },
      onChanged: (value) {
        setState(() => _selectedLocation = value);
        _onFieldChanged();
      },
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    int maxLines = 1,
  }) {
    return CoachProfileTextField(
      label: label,
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return BlocConsumer<CoachProfileCubit, CoachProfileState>(
      listener: (context, state) {
        if (state is CoachProfileLoaded) {
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
        } else if (state is CoachProfileError) {
          _retryingLoad = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isUpdating = state is CoachProfileUpdating;
        return Column(
          children: [
            if (state is CoachProfileError && state.isConnectionError)
              ConnectionErrorView(
                compact: true,
                onRetry: () {
                  _retryingLoad = true;
                  context.read<CoachProfileCubit>().loadProfile(
                    forceRefresh: true,
                  );
                },
              ),
            CoachEditProfileSaveAction(
              hasChanges: _hasChanges,
              isUpdating: isUpdating,
              onSave: _saveProfile,
            ),
          ],
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
    final newBio = _bioController.text != _initialBio
        ? _bioController.text
        : null;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No changes to save.')));
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
