import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/repositories/auth_repository.dart';

class RequestPasswordResetUseCase {
  final AuthRepository _repository;
  const RequestPasswordResetUseCase(this._repository);

  Future<ApiResult<String>> call({required String email}) {
    return _repository.requestPasswordReset(email: email);
  }
}