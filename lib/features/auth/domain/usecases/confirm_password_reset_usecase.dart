import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/repositories/auth_repository.dart';

class ConfirmPasswordResetUseCase {
  final AuthRepository _repository;
  const ConfirmPasswordResetUseCase(this._repository);

  Future<ApiResult<void>> call({
    required String email,
    required String code,
    required String password,
  }) {
    return _repository.confirmPasswordReset(
      email: email,
      code: code,
      password: password,
    );
  }
}