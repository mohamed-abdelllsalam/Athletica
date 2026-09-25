import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/entities/user_entity.dart';
import 'package:athletica/features/auth/domain/repositories/auth_repository.dart';

class GoogleLoginUseCase {
  final AuthRepository _repository;

  const GoogleLoginUseCase(this._repository);

  Future<ApiResult<AuthResponseEntity>> call({
    required String idToken,
    String? role,
  }) => _repository.loginWithGoogle(idToken: idToken, role: role);
}
