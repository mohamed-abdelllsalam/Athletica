import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/profile/domain/repositories/profile_repository.dart';

class DeleteProfileImageUseCase {
  const DeleteProfileImageUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ApiResult<void>> call() => _repository.deleteProfileImage();
}
