import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/assigned/domain/entities/client_assigned.dart';
import 'package:athletica/features/assigned/domain/repositories/assigned_repository.dart';

class GetAssignedPlansUseCase {
  const GetAssignedPlansUseCase(this._repository);

  final AssignedRepository _repository;

  Future<ApiResult<ClientAssigned>> call() =>
      _repository.getAssignedPlans();
}

class AssignClientWorkoutUseCase {
  const AssignClientWorkoutUseCase(this._repository);

  final AssignedRepository _repository;

  Future<ApiResult<void>> call(String templateId) =>
      _repository.assignWorkoutTemplate(templateId);
}

class AssignClientNutritionUseCase {
  const AssignClientNutritionUseCase(this._repository);

  final AssignedRepository _repository;

  Future<ApiResult<void>> call(String templateId) =>
      _repository.assignNutritionTemplate(templateId);
}
