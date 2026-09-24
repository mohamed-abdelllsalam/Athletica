import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/achievements/domain/repositories/achievements_repository.dart';

class DeleteCoachAchievementUseCase {
  const DeleteCoachAchievementUseCase(this._repository);

  final AchievementsRepository _repository;

  Future<ApiResult<void>> call(String id) =>
      _repository.deleteCoachAchievement(id);
}
