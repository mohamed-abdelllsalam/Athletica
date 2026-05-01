import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';

abstract class CoachClientsRepository {
  Future<ApiResult<List<CoachClient>>> getClientsByTrainerId(String trainerId);
}
