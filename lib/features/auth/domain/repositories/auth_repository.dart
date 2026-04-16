import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<ApiResult<AuthResponseEntity>> login({
    required String email,
    required String password,
  });

  Future<ApiResult<void>> registerClient({
    required String name,
    required String phone,
    required String email,
    required String password,
  });

  Future<ApiResult<void>> registerTrainer({
    required String name,
    required String phone,
    required String email,
    required String password,
  });

  Future<ApiResult<void>> logout();
}
