import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/profile/domain/entities/coach_profile_entity.dart';
import 'package:athletica/features/coach/profile/domain/repositories/coach_profile_repository.dart';

class GetCoachProfileUseCase {
  const GetCoachProfileUseCase(this._repository);

  final CoachProfileRepository _repository;

  Future<ApiResult<CoachProfileEntity>> call(String trainerId) =>
      _repository.getCoachProfile(trainerId);
}
