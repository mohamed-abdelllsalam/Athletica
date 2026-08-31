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
        content: const Text('Are you sure you want to delete your profile photo?'),
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

        return Container(
          width: double.infinity,
          color: AppColors.primaryAppColor,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isUploading)
                const CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                )
              else if (profileImage != null && profileImage.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    profileImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFF1A1A1A),
                      child: Icon(
                        Icons.person,
                        size: 120.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFF1A1A1A),
                  child: Icon(
                    Icons.person,
                    size: 120.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewActions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Preview',
            style: AppTextStyles.bold20(context)
                .copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text(
                'Save Photo',
                style: AppTextStyles.semiBold15(context)
                    .copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _cancelPreview,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.textTertiary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text(
                'Cancel',
                style: AppTextStyles.semiBold15(context)
                    .copyWith(color: AppColors.textSecondary),
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

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Profile Photo',
            style: AppTextStyles.bold20(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _PhotoOptionButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _PhotoOptionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
          if (hasImage) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _deleteImage,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: Text(
                  'Delete Photo',
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
          ],
        ],
      ),
    );
  }
}

class _PhotoOptionButton extends StatelessWidget {
  const _PhotoOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.textTertiary, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 26.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: AppTextStyles.medium13(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
