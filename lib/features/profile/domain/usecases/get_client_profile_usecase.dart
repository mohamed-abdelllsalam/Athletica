import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/profile/domain/entities/client_profile_entity.dart';
import 'package:athletica/features/profile/domain/repositories/profile_repository.dart';

class GetClientProfileUseCase {
  const GetClientProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ApiResult<ClientProfileEntity>> call() => _repository.getClientProfile();
}