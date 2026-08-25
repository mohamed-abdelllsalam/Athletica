import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_assigned_client.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';

abstract class CoachClientsRepository {
  Future<ApiResult<List<CoachClient>>> getClientsByTrainerId(String trainerId);
  Future<ApiResult<List<CoachAssignedClient>>> getAssignedClients();
  Future<ApiResult<void>> removeAssignedClient(String coachClientId);
}
