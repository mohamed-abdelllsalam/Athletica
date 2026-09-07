import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';
import 'package:athletica/features/profile/domain/repositories/profile_repository.dart';

class UpdateCoachProfileUseCase {
  const UpdateCoachProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ApiResult<CoachProfileEntity>> call({
    String? username,
    String? bio,
    String? specialization,
    String? phoneNumber,
    String? location,
  }) =>
      _repository.updateCoachProfile(
        username: username,
        bio: bio,
        specialization: specialization,
        phoneNumber: phoneNumber,
        location: location,
      );
}
