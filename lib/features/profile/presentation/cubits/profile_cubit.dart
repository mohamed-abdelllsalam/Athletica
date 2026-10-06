import 'dart:io';

import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/profile/domain/usecases/delete_profile_image_usecase.dart';
import 'package:athletica/features/profile/domain/usecases/get_client_profile_usecase.dart';
import 'package:athletica/features/profile/domain/usecases/update_client_profile_usecase.dart';
import 'package:athletica/features/profile/domain/usecases/upload_profile_image_usecase.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._getClientProfile,
    this._updateClientProfile,
    this._uploadProfileImage,
    this._deleteProfileImage,
  ) : super(ProfileInitial());

  final GetClientProfileUseCase _getClientProfile;
  final UpdateClientProfileUseCase _updateClientProfile;
  final UploadProfileImageUseCase _uploadProfileImage;
  final DeleteProfileImageUseCase _deleteProfileImage;

  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && (state is ProfileLoaded || state is ProfileLoading)) {
      return;
    }
    final currentProfile = state is ProfileLoaded
        ? (state as ProfileLoaded).profile
        : null;
    if (currentProfile == null) emit(ProfileLoading());
    final result = await _getClientProfile();
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(ProfileLoaded(data));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(ProfileError(failure.message, profile: currentProfile));
    }
  }

  Future<void> updateProfile({
    String? username,
    String? gender,
    DateTime? birthDate,
    double? height,
    double? weight,
    String? goal,
    String? phoneNumber,
    String? location,
  }) async {
    final currentProfile = state is ProfileLoaded
        ? (state as ProfileLoaded).profile
        : null;
    if (currentProfile != null) {
      emit(ProfileUpdating(currentProfile));
    }
    final result = await _updateClientProfile(
      username: username,
      gender: gender,
      birthDate: birthDate,
      height: height,
      weight: weight,
      goal: goal,
      phoneNumber: phoneNumber,
      location: location,
    );
    switch (result) {
      case ApiSuccess():
        if (isClosed) return;
        await loadProfile(forceRefresh: true);
      case ApiError(:final failure):
        if (isClosed) return;
        emit(ProfileError(failure.message, profile: currentProfile));
    }
  }

  Future<void> uploadImage(File imageFile) async {
    final currentProfile = state is ProfileLoaded
        ? (state as ProfileLoaded).profile
        : null;
    if (currentProfile != null) {
      emit(ProfileImageUploading(currentProfile));
    }
    final result = await _uploadProfileImage(imageFile);
    switch (result) {
      case ApiSuccess():
        if (isClosed) return;
        await loadProfile(forceRefresh: true);
      case ApiError(:final failure):
        if (isClosed) return;
        emit(ProfileError(failure.message, profile: currentProfile));
    }
  }

  Future<void> deleteImage() async {
    final currentProfile = state is ProfileLoaded
        ? (state as ProfileLoaded).profile
        : null;
    if (currentProfile != null) {
      emit(ProfileImageUploading(currentProfile));
    }
    final result = await _deleteProfileImage();
    switch (result) {
      case ApiSuccess():
        if (isClosed) return;
        await loadProfile(forceRefresh: true);
      case ApiError(:final failure):
        if (isClosed) return;
        emit(ProfileError(failure.message, profile: currentProfile));
    }
  }
}
