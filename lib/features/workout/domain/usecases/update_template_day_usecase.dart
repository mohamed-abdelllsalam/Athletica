import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class UpdateTemplateDayUseCase {
  const UpdateTemplateDayUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<WorkoutTemplateEntry>> call(
    String templateId,
    String dayId, {
    String? title,
    int? dayNumber,
    bool? isRest,
  }) =>
      _repository.updateTemplateDay(
        templateId,
        dayId,
        title: title,
        dayNumber: dayNumber,
        isRest: isRest,
      );
}
