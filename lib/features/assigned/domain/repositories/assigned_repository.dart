import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/assigned/domain/entities/client_assigned.dart';

abstract class AssignedRepository {
  Future<ApiResult<ClientAssigned>> getAssignedPlans();
  Future<ApiResult<void>> assignWorkoutTemplate(String templateId);
  Future<ApiResult<void>> assignNutritionTemplate(String templateId);
}
