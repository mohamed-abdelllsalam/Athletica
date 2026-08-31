import 'dart:io';

import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/profile/data/models/user_profile_model.dart';
import 'package:dio/dio.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile({Map<String, dynamic>? data});
  Future<String> uploadProfileImage(File imageFile);
  Future<void> deleteProfileImage();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data') && responseData['data'] is Map) {
        return responseData['data'] as Map<String, dynamic>;
      }
      return responseData;
    }
    throw const FormatException('Unexpected response format');
  }

  @override
  Future<UserProfileModel> getProfile() async {
    final response = await _dio.get(ApiEndpoints.profile);
    return UserProfileModel.fromJson(_extractData(response.data));
  }

  @override
  Future<UserProfileModel> updateProfile({Map<String, dynamic>? data}) async {
    final response = await _dio.patch(
      ApiEndpoints.profile,
      data: data,
    );
    return UserProfileModel.fromJson(_extractData(response.data));
  }

  @override
  Future<String> uploadProfileImage(File imageFile) async {
    final fileName = imageFile.path.split('/').last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });
    final response = await _dio.post(
      ApiEndpoints.profileImage,
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );
    final data = _extractData(response.data);
    return data['profile_image']?.toString() ??
        data['profileImage']?.toString() ??
        '';
  }

  @override
  Future<void> deleteProfileImage() async {
    await _dio.delete(ApiEndpoints.profileImage);
  }
}
