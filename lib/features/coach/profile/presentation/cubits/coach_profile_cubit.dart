import 'dart:io';

import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/profile/presentation/cubits/coach_profile_state.dart';
import 'package:athletica/features/profile/domain/usecases/delete_profile_image_usecase.dart';
import 'package:athletica/features/profile/domain/usecases/get_coach_profile_usecase.dart';
import 'package:athletica/features/profile/domain/usecases/update_coach_profile_usecase.dart';
import 'package:athletica/features/profile/domain/usecases/upload_profile_image_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachProfileCubit extends Cubit<CoachProfileState> {
  CoachProfileCubit(
    this._getCoachProfile,
    this._updateCoachProfile,
    this._uploadProfileImage,
    this._deleteProfileImage,
  ) : super(const CoachProfileInitial());

  final GetCoachProfileUseCase _getCoachProfile;
  final UpdateCoachProfileUseCase _updateCoachProfile;
  final UploadProfileImageUseCase _uploadProfileImage;
  final DeleteProfileImageUseCase _deleteProfileImage;

  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        (state is CoachProfileLoaded || state is CoachProfileLoading)) {
      return;
    }
    emit(const CoachProfileLoading());
    final result = await _getCoachProfile();
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(CoachProfileLoaded(data));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(CoachProfileError(failure.message));
    }
  }

  Future<void> updateProfile({
    String? bio,
    String? specialization,
  }) async {
    final currentProfile =
        state is CoachProfileLoaded ? (state as CoachProfileLoaded).profile : null;
    if (currentProfile != null) {
      emit(CoachProfileUpdating(currentProfile));
    }
    final result = await _updateCoachProfile(
      bio: bio,
      specialization: specialization,
    );
    switch (result) {
      case ApiSuccess():
        if (isClosed) return;
        await loadProfile(forceRefresh: true);
      case ApiError(:final failure):
        if (isClosed) return;
        emit(CoachProfileError(failure.message, profile: currentProfile));
    }
  }

  Future<void> uploadImage(File imageFile) async {
    final currentProfile =
        state is CoachProfileLoaded ? (state as CoachProfileLoaded).profile : null;
    if (currentProfile != null) {
      emit(CoachProfileImageUploading(currentProfile));
    }
    final result = await _uploadProfileImage(imageFile);
    switch (result) {
      case ApiSuccess():
        if (isClosed) return;
        await loadProfile(forceRefresh: true);
      case ApiError(:final failure):
        if (isClosed) return;
        emit(CoachProfileError(failure.message, profile: currentProfile));
    }
  }

  Future<void> deleteImage() async {
    final currentProfile =
        state is CoachProfileLoaded ? (state as CoachProfileLoaded).profile : null;
    if (currentProfile != null) {
      emit(CoachProfileImageUploading(currentProfile));
    }
    final result = await _deleteProfileImage();
    switch (result) {
      case ApiSuccess():
        if (isClosed) return;
        await loadProfile(forceRefresh: true);
      case ApiError(:final failure):
        if (isClosed) return;
        emit(CoachProfileError(failure.message, profile: currentProfile));
    }
  }
}
