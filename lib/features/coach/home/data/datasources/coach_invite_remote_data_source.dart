import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/coach/home/data/models/coach_invite_code_model.dart';
import 'package:dio/dio.dart';

abstract class CoachInviteRemoteDataSource {
  Future<CoachInviteCodeModel> createInviteCode();
}

class CoachInviteRemoteDataSourceImpl implements CoachInviteRemoteDataSource {
  const CoachInviteRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<CoachInviteCodeModel> createInviteCode() async {
    final response = await _dio.post(ApiEndpoints.trainerInviteCodes);
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    return CoachInviteCodeModel.fromJson(data);
  }
}
