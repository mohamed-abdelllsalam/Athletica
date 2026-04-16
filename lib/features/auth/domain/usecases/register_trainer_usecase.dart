import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/repositories/auth_repository.dart';

class RegisterTrainerUseCase {
  final AuthRepository _repository;
  const RegisterTrainerUseCase(this._repository);

  Future<ApiResult<void>> call({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) {
    return _repository.registerTrainer(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
  }
}
