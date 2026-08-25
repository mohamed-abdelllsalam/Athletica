import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/client_coach/data/models/assigned_coach_model.dart';
import 'package:athletica/features/client_coach/data/models/coach_link_request_model.dart';
import 'package:dio/dio.dart';

abstract class ClientCoachRemoteDataSource {
  /// Submits an invite token. Returns the created/reset request.
  Future<CoachLinkRequestModel> submitInviteToken(String token);

  /// Returns null when the client has no assigned coach (the API answers
  /// with the `no_coach_assigned` error key); other errors are thrown.
  Future<AssignedCoachModel?> getMyCoach();

  Future<void> leaveCoach();
}

class ClientCoachRemoteDataSourceImpl implements ClientCoachRemoteDataSource {
  const ClientCoachRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<CoachLinkRequestModel> submitInviteToken(String token) async {
    final response = await _dio.post(
      ApiEndpoints.coachClientRequests,
      data: {'token': token},
    );
    final data = response.data as Map<String, dynamic>? ?? {};
    return CoachLinkRequestModel.fromJson(data);
  }

  @override
  Future<AssignedCoachModel?> getMyCoach() async {
    try {
      final response = await _dio.get(ApiEndpoints.clientCoach);
      final data = response.data as Map<String, dynamic>? ?? {};
      return AssignedCoachModel.fromJson(data);
    } on DioException catch (e) {
      final body = e.response?.data;
      final errorKey = body is Map<String, dynamic> ? body['error'] : null;
      if (_normalizeErrorKey(errorKey) == 'no_coach_assigned') {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> leaveCoach() async {
    await _dio.post(ApiEndpoints.clientLeaveCoach);
  }
}

/// The API documents snake_case error keys but responses carry
/// human-readable values (e.g. "No coach assigned"); normalize both so the
/// empty-state detection matches either shape.
String? _normalizeErrorKey(Object? key) =>
    key is String ? key.toLowerCase().trim().replaceAll(' ', '_') : null;
