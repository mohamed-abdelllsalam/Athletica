import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/coach/profile/data/models/coach_profile_model.dart';
import 'package:dio/dio.dart';

abstract class CoachProfileRemoteDataSource {
  Future<CoachProfileModel> getCoachProfile(String trainerId);
}

class CoachProfileRemoteDataSourceImpl implements CoachProfileRemoteDataSource {
  const CoachProfileRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<CoachProfileModel> getCoachProfile(String trainerId) async {
    final response = await _dio.get(ApiEndpoints.trainerProfile(trainerId));
    return CoachProfileModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
