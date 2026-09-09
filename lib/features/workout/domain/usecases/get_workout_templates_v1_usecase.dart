import 'package:athletica/core/network/api_pagination.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class GetWorkoutTemplatesV1UseCase {
  const GetWorkoutTemplatesV1UseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<({List<WorkoutTemplateEntry> items, ApiPagination pagination})>>
      call({int page = 1, int pageSize = 10}) =>
          _repository.getTemplates(page: page, pageSize: pageSize);
}
