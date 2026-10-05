import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/entities/auth_status.dart';
import 'package:athletica/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<ApiResult<AuthResponseEntity>> login({
    required String email,
    required String password,
  });

  Future<ApiResult<AuthResponseEntity>> loginWithGoogle({
    required String idToken,
    String? role,
  });

  Future<ApiResult<void>> registerClient({
    required String name,
    required String email,
    required String password,
  });

  Future<ApiResult<void>> registerTrainer({
    required String name,
    required String email,
    required String password,
  });

  Future<ApiResult<AuthResponseEntity>> verifyEmail({
    required String email,
    required String code,
  });

  Future<ApiResult<void>> resendVerification({required String email});

  Future<ApiResult<String>> requestPasswordReset({required String email});

  Future<ApiResult<void>> confirmPasswordReset({
    required String email,
    required String code,
    required String password,
  });

  Future<ApiResult<void>> logout();

  Future<AuthStatus> getAuthStatus();

  Future<void> markProfileComplete();

  Future<ApiResult<bool>> checkClientProfileCompletion();
}
