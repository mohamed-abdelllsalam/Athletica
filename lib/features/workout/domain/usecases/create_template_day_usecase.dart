import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class CreateTemplateDayUseCase {
  const CreateTemplateDayUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<WorkoutTemplateEntry>> call(
    String templateId, {
    required String title,
    String? note,
  }) =>
      _repository.createTemplateDay(templateId, title: title, note: note);
}
