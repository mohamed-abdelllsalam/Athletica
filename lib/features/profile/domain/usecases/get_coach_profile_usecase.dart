import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';
import 'package:athletica/features/profile/domain/repositories/profile_repository.dart';

class GetCoachProfileUseCase {
  const GetCoachProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ApiResult<CoachProfileEntity>> call() => _repository.getCoachProfile();
}
