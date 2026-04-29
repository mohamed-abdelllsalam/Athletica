import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/profile/data/models/client_profile_model.dart';
import 'package:dio/dio.dart';

abstract class ProfileRemoteDataSource {
  Future<ClientProfileModel> getClientProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<ClientProfileModel> getClientProfile() async {
    final response = await _dio.get(ApiEndpoints.clientProfile);
    return ClientProfileModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}