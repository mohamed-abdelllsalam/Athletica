import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;
  const LogoutUseCase(this._repository);

  Future<ApiResult<void>> call() {
    return _repository.logout();
  }
}
