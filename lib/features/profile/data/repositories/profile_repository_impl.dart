import 'dart:io';

import 'package:athletica/core/errors/api_error_mapper.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';
import 'package:athletica/features/profile/domain/repositories/profile_repository.dart';
import 'package:dio/dio.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._dataSource);

  final ProfileRemoteDataSource _dataSource;

  @override
  Future<ApiResult<CoachProfileEntity>> getCoachProfile() async {
    try {
      final model = await _dataSource.getProfile();
      return ApiSuccess(model.toCoachEntity());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<ClientProfileEntity>> getClientProfile() async {
    try {
      final model = await _dataSource.getProfile();
      return ApiSuccess(model.toClientEntity());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<CoachProfileEntity>> updateCoachProfile({
    String? username,
    String? bio,
    String? specialization,
    String? phoneNumber,
    String? location,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (bio != null) data['bio'] = bio;
      if (specialization != null) data['specialization'] = specialization;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (location != null) data['location'] = location;
      // Never send an empty PATCH body: the backend answers 400
      // (no_fields_to_update) when nothing effective changed.
      if (data.isEmpty) {
        return const ApiError(ServerFailure('No changes to save.'));
      }
      final model = await _dataSource.updateProfile(data: data);
      return ApiSuccess(model.toCoachEntity());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<ClientProfileEntity>> updateClientProfile({
    String? username,
    String? gender,
    DateTime? birthDate,
    double? height,
    double? weight,
    String? goal,
    String? phoneNumber,
    String? location,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (gender != null) data['gender'] = gender;
      if (birthDate != null) {
        data['birth_date'] =
            '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
      }
      if (height != null) data['height'] = height;
      if (weight != null) data['weight'] = weight;
      if (goal != null) data['goal'] = goal;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (location != null) data['location'] = location;
      // Never send an empty PATCH body: the backend answers 400
      // (no_fields_to_update) when nothing effective changed.
      if (data.isEmpty) {
        return const ApiError(ServerFailure('No changes to save.'));
      }
      final model = await _dataSource.updateProfile(data: data);
      return ApiSuccess(model.toClientEntity());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<String>> uploadProfileImage(File imageFile) async {
    try {
      final url = await _dataSource.uploadProfileImage(imageFile);
      return ApiSuccess(url);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteProfileImage() async {
    try {
      await _dataSource.deleteProfileImage();
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
