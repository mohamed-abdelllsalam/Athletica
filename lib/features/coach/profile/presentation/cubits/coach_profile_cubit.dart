import 'dart:io';

import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';
import 'package:athletica/core/errors/failures.dart';
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

  CoachProfileEntity? get _currentProfile => switch (state) {
    CoachProfileLoaded(:final profile) => profile,
    CoachProfileUpdating(:final profile) => profile,
    CoachProfileImageUploading(:final profile) => profile,
    CoachProfileImageUploaded(:final profile) => profile,
    CoachProfileImageDeleted(:final profile) => profile,
    CoachProfileError(:final profile) => profile,
    _ => null,
  };

  bool _loading = false;

  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (_loading || isClosed) return;
    if (!forceRefresh &&
        (state is CoachProfileLoaded || state is CoachProfileLoading)) {
      return;
    }
    _loading = true;
    final currentProfile = _currentProfile;
    if (currentProfile == null) emit(const CoachProfileLoading());
    final result = await _getCoachProfile();
    _loading = false;
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(CoachProfileLoaded(data));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(
          CoachProfileError(
            failure.message,
            profile: failure is NetworkFailure ? currentProfile : null,
            isConnectionError: failure is NetworkFailure,
          ),
        );
    }
  }

  Future<void> updateProfile({
    String? username,
    String? bio,
    String? specialization,
    String? phoneNumber,
    String? location,
  }) async {
    final currentProfile = _currentProfile;
    if (currentProfile != null) {
      emit(CoachProfileUpdating(currentProfile));
    }
    final result = await _updateCoachProfile(
      username: username,
      bio: bio,
      specialization: specialization,
      phoneNumber: phoneNumber,
      location: location,
    );
    switch (result) {
      case ApiSuccess():
        if (isClosed) return;
        await loadProfile(forceRefresh: true);
      case ApiError(:final failure):
        if (isClosed) return;
        emit(
          CoachProfileError(
            failure.message,
            profile: currentProfile,
            isConnectionError: failure is NetworkFailure,
          ),
        );
    }
  }

  Future<void> uploadImage(File imageFile) async {
    final currentProfile = _currentProfile;
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
        emit(
          CoachProfileError(
            failure.message,
            profile: currentProfile,
            isConnectionError: failure is NetworkFailure,
          ),
        );
    }
  }

  Future<void> deleteImage() async {
    final currentProfile = _currentProfile;
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
        emit(
          CoachProfileError(
            failure.message,
            profile: currentProfile,
            isConnectionError: failure is NetworkFailure,
          ),
        );
    }
  }
}
