import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/repositories/auth_repository.dart';

class ResendVerificationUseCase {
  final AuthRepository _repository;
  const ResendVerificationUseCase(this._repository);

  Future<ApiResult<void>> call({required String email}) {
    return _repository.resendVerification(email: email);
  }
}