import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/streak/domain/entities/streak_data.dart';
import 'package:athletica/features/streak/domain/repositories/streak_repository.dart';

class GetCoachClientStreakUseCase {
  const GetCoachClientStreakUseCase(this._repository);

  final StreakRepository _repository;

  Future<ApiResult<StreakData>> call(String coachClientId) =>
      _repository.getCoachClientStreak(coachClientId);
}
