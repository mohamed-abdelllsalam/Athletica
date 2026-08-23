import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/assigned_client.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';

class GetAssignedClientsUseCase {
  const GetAssignedClientsUseCase(this._repository);

  final NutritionTemplatesRepository _repository;

  Future<ApiResult<List<AssignedClient>>> call() =>
      _repository.getAssignedClients();
}
