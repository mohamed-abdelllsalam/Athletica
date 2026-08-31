import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';
import 'package:athletica/features/profile/domain/repositories/profile_repository.dart';

class UpdateCoachProfileUseCase {
  const UpdateCoachProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ApiResult<CoachProfileEntity>> call({
    String? bio,
    String? specialization,
  }) =>
      _repository.updateCoachProfile(
        bio: bio,
        specialization: specialization,
      );
}
