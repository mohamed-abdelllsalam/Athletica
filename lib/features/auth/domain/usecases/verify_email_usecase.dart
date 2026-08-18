import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/repositories/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository _repository;
  const VerifyEmailUseCase(this._repository);

  Future<ApiResult<void>> call({
    required String email,
    required String code,
  }) {
    return _repository.verifyEmail(email: email, code: code);
  }
}