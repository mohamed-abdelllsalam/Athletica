import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/repositories/auth_repository.dart';

class RegisterClientUseCase {
  final AuthRepository _repository;
  const RegisterClientUseCase(this._repository);

  Future<ApiResult<void>> call({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) {
    return _repository.registerClient(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
  }
}
