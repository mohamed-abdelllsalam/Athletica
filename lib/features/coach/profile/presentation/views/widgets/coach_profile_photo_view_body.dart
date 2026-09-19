import 'coach_profile_photo_preview_actions.dart';
import 'coach_profile_photo_options.dart';
import 'coach_profile_photo_image.dart';
import 'dart:io';

import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/profile/presentation/cubits/coach_profile_cubit.dart';
import 'package:athletica/features/coach/profile/presentation/cubits/coach_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CoachProfilePhotoViewBody extends StatefulWidget {
  const CoachProfilePhotoViewBody({super.key});

  @override
  State<CoachProfilePhotoViewBody> createState() =>
      _CoachProfilePhotoViewBodyState();
}

class _CoachProfilePhotoViewBodyState extends State<CoachProfilePhotoViewBody> {
  final ImagePicker _picker = ImagePicker();
  File? _pendingImage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null || !mounted) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Photo',
            toolbarColor: AppColors.primaryAppColor,
            toolbarWidgetColor: AppColors.textPrimary,
            activeControlsWidgetColor: AppColors.primaryBlue,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Photo',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedFile != null && mounted) {
        setState(() => _pendingImage = File(croppedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveImage() {
    if (_pendingImage != null) {
      context.read<CoachProfileCubit>().uploadImage(_pendingImage!);
      setState(() => _pendingImage = null);
    }
  }

  void _cancelPreview() {
    setState(() => _pendingImage = null);
  }

  Future<void> _deleteImage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Photo'),
        content: const Text(
          'Are you sure you want to delete your profile photo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<CoachProfileCubit>().deleteImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CoachProfileCubit, CoachProfileState>(
      listenWhen: (prev, curr) =>
          (prev is CoachProfileImageUploading) &&
          (curr is CoachProfileLoaded || curr is CoachProfileError),
      listener: (context, state) {
        if (state is CoachProfileLoaded && mounted) {
          Navigator.of(context).pop();
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
                child: _pendingImage != null
                    ? _buildPreview()
                    : _buildCurrentImage(),
              ),
              _pendingImage != null
                  ? _buildPreviewActions(context)
                  : _buildBottomSheet(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.file(
        _pendingImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildCurrentImage() {
    return BlocBuilder<CoachProfileCubit, CoachProfileState>(
      builder: (context, state) {
        final profileImage = switch (state) {
          CoachProfileLoaded(:final profile) => profile.profileImage,
          CoachProfileImageUploading(:final profile) => profile.profileImage,
          CoachProfileImageUploaded(:final profile) => profile.profileImage,
          CoachProfileImageDeleted(:final profile) => profile.profileImage,
          _ => null,
        };
        final isUploading = state is CoachProfileImageUploading;

        return CoachProfilePhotoImage(
          profileImage: profileImage,
          isUploading: isUploading,
        );
      },
    );
  }

  Widget _buildPreviewActions(BuildContext context) {
    return CoachProfilePhotoPreviewActions(
      onSave: _saveImage,
      onCancel: _cancelPreview,
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
              'Profile photo',
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

  Widget _buildBottomSheet(BuildContext context) {
    final profileState = context.watch<CoachProfileCubit>().state;
    final hasImage = switch (profileState) {
      CoachProfileLoaded(:final profile) =>
        profile.profileImage != null && profile.profileImage!.isNotEmpty,
      CoachProfileImageUploaded(:final profile) =>
        profile.profileImage != null && profile.profileImage!.isNotEmpty,
      _ => false,
    };

    return CoachProfilePhotoOptions(
      hasImage: hasImage,
      onCamera: () => _pickImage(ImageSource.camera),
      onGallery: () => _pickImage(ImageSource.gallery),
      onDelete: _deleteImage,
    );
  }
}
