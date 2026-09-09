import 'package:athletica/core/network/api_pagination.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class GetWorkoutPlansUseCase {
  const GetWorkoutPlansUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<({List<WorkoutPlanSummary> items, ApiPagination pagination})>>
      call({
    required String clientId,
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) =>
          _repository.getPlans(
            clientId: clientId,
            isActive: isActive,
            page: page,
            pageSize: pageSize,
          );
}
