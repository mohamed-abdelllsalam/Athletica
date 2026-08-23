import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/coach/clients/data/models/join_request_model.dart';
import 'package:dio/dio.dart';

abstract class CoachJoinRequestsRemoteDataSource {
  Future<List<JoinRequestModel>> getJoinRequests();
  Future<void> acceptJoinRequest(String requestId);
  Future<void> rejectJoinRequest(String requestId);
}

class CoachJoinRequestsRemoteDataSourceImpl
    implements CoachJoinRequestsRemoteDataSource {
  const CoachJoinRequestsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<JoinRequestModel>> getJoinRequests() async {
    final response = await _dio.get(ApiEndpoints.coachRequests);
    final data = response.data as Map<String, dynamic>? ?? {};
    return (data['requests'] as List<dynamic>? ?? [])
        .map((e) => JoinRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> acceptJoinRequest(String requestId) async {
    await _dio.post(ApiEndpoints.coachRequestAccept(requestId));
  }

  @override
  Future<void> rejectJoinRequest(String requestId) async {
    await _dio.post(ApiEndpoints.coachRequestReject(requestId));
  }
}
