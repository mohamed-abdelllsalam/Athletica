import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';
import 'package:athletica/features/profile/domain/repositories/profile_repository.dart';

class UpdateClientProfileUseCase {
  const UpdateClientProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ApiResult<ClientProfileEntity>> call({
    String? gender,
    DateTime? birthDate,
    double? height,
    double? weight,
    String? goal,
  }) =>
      _repository.updateClientProfile(
        gender: gender,
        birthDate: birthDate,
        height: height,
        weight: weight,
        goal: goal,
      );
}
