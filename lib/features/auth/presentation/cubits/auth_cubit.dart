import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/confirm_password_reset_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/login_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/logout_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/register_client_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/register_trainer_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthCubit extends Cubit<AuthState> {
  static const String _serverClientId =
      '481799697583-s8eoafsguqvjllo9foju8k06db2296np.apps.googleusercontent.com';
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _serverClientId,
  );

  final LoginUseCase _loginUseCase;
  final RegisterClientUseCase _registerClientUseCase;
  final RegisterTrainerUseCase _registerTrainerUseCase;
  final VerifyEmailUseCase _verifyEmailUseCase;
  final ResendVerificationUseCase _resendVerificationUseCase;
  final RequestPasswordResetUseCase _requestPasswordResetUseCase;
  final ConfirmPasswordResetUseCase _confirmPasswordResetUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterClientUseCase registerClientUseCase,
    required RegisterTrainerUseCase registerTrainerUseCase,
    required VerifyEmailUseCase verifyEmailUseCase,
    required ResendVerificationUseCase resendVerificationUseCase,
    required RequestPasswordResetUseCase requestPasswordResetUseCase,
    required ConfirmPasswordResetUseCase confirmPasswordResetUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required GoogleLoginUseCase googleLoginUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerClientUseCase = registerClientUseCase,
        _registerTrainerUseCase = registerTrainerUseCase,
        _verifyEmailUseCase = verifyEmailUseCase,
        _resendVerificationUseCase = resendVerificationUseCase,
        _requestPasswordResetUseCase = requestPasswordResetUseCase,
        _confirmPasswordResetUseCase = confirmPasswordResetUseCase,
        _logoutUseCase = logoutUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        _googleLoginUseCase = googleLoginUseCase,
        super(AuthInitial());

  Future<void> signInWithGoogle({
    required Future<String?> Function() pickRole,
  }) async {
    emit(AuthLoading());
    try {
      var account = await _authenticateGoogle();
      if (account == null) {
        if (!isClosed) emit(AuthInitial());
        return;
      }

      var idToken = (await account.authentication).idToken;
      if (idToken == null || idToken.isEmpty) {
        account = await _authenticateGoogle();
        if (account == null) {
          if (!isClosed) emit(AuthInitial());
          return;
        }
        idToken = (await account.authentication).idToken;
      }
      if (idToken == null || idToken.isEmpty) {
        throw const _GoogleSignInFlowException(
          'Google did not return an ID token. Check the Google sign-in configuration and try again.',
        );
      }

      var result = await _googleLoginUseCase(idToken: idToken);
      if (result case ApiError(:final failure)) {
        final needsRole = failure is GoogleRoleRequiredFailure;
        final invalidToken = failure is GoogleInvalidTokenFailure;
        if (needsRole) {
          final role = await pickRole();
          if (role == null) {
            await _googleSignIn.signOut();
            if (!isClosed) emit(AuthInitial());
            return;
          }
          result = await _googleLoginUseCase(idToken: idToken, role: role);
        } else if (invalidToken || failure is GoogleIdTokenRequiredFailure) {
          final refreshed = await _authenticateGoogle();
          if (refreshed == null) {
            if (!isClosed) emit(AuthInitial());
            return;
          }
          final refreshedToken = (await refreshed.authentication).idToken;
          if (refreshedToken == null || refreshedToken.isEmpty) {
            throw const _GoogleSignInFlowException(
              'Google did not return an ID token. Check the Google sign-in configuration and try again.',
            );
          }
          result = await _googleLoginUseCase(idToken: refreshedToken);
        }
      }

      if (isClosed) return;
      switch (result) {
        case ApiSuccess(:final data):
          emit(LoginSuccess(data));
        case ApiError(:final failure):
          emit(AuthFailureState(failure.message));
      }
    } on _GoogleSignInFlowException catch (error) {
      if (!isClosed) emit(AuthFailureState(error.message));
    } catch (_) {
      if (!isClosed) {
        emit(AuthFailureState('Google sign-in failed. Please try again.'));
      }
    }
  }

  Future<GoogleSignInAccount?> _authenticateGoogle() async {
    try {
      return await _googleSignIn.signIn();
    } on PlatformException catch (error) {
      // google_sign_in v6 reports user cancellation as a PlatformException.
      final code = error.code.toLowerCase();
      if (code.contains('cancel') || code.contains('sign_in_canceled')) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await _loginUseCase(email: email, password: password);
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(LoginSuccess(data));
      case ApiError(:final failure):
        if (failure is EmailNotVerifiedFailure) {
          if (isClosed) return;
          emit(EmailVerificationRequired(failure.message));
        } else {
          if (isClosed) return;
          emit(AuthFailureState(failure.message));
        }
    }
  }

  Future<void> registerClient({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await _registerClientUseCase(
      name: name,
      email: email,
      password: password,
    );
    switch (result) {
      case ApiSuccess():
        if (isClosed) return;
        emit(RegisterSuccess());
      case ApiError(:final failure):
        if (isClosed) return;
        emit(AuthFailureState(failure.message));
    }
  }

  Future<void> registerTrainer({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await _registerTrainerUseCase(
      name: name,
      email: email,
      password: password,
    );
    switch (result) {
      case ApiSuccess():
        if (isClosed) return;
        emit(RegisterSuccess());
      case ApiError(:final failure):
        if (isClosed) return;
        emit(AuthFailureState(failure.message));
    }
  }

  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    emit(VerificationLoading());
    final result = await _verifyEmailUseCase(email: email, code: code);
    switch (result) {
      case ApiSuccess():
        if (isClosed) return;
        emit(VerificationSuccess());
      case ApiError(:final failure):
        if (isClosed) return;
        emit(AuthFailureState(failure.message));
    }
  }

  Future<void> resendVerification({required String email}) async {
    emit(VerificationLoading());
    final result = await _resendVerificationUseCase(email: email);
    switch (result) {
      case ApiSuccess():
        if (isClosed) return;
        emit(VerificationCodeResent());
      case ApiError(:final failure):
        if (isClosed) return;
        emit(AuthFailureState(failure.message));
    }
  }

  Future<void> requestPasswordReset({required String email}) async {
    emit(ResetRequestLoading());
    final result = await _requestPasswordResetUseCase(email: email);
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(ResetRequestSuccess(data));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(AuthFailureState(failure.message));
    }
  }

  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String password,
  }) async {
    emit(ResetConfirmLoading());
    final result = await _confirmPasswordResetUseCase(
      email: email,
      code: code,
      password: password,
    );
    switch (result) {
      case ApiSuccess():
        if (isClosed) return;
        emit(ResetPasswordSuccess());
      case ApiError(:final failure):
        if (isClosed) return;
        emit(AuthFailureState(failure.message));
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final status = await _checkAuthStatusUseCase();
      if (isClosed) return;
      emit(AuthStatusChecked(status));
    } catch (e) {
      if (isClosed) return;
      emit(AuthFailureState('Failed to verify session. Please try again.'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    final result = await _logoutUseCase();
    switch (result) {
      case ApiSuccess():
        try {
          await _googleSignIn.signOut();
        } catch (_) {}
        if (isClosed) return;
        emit(AuthInitial());
      case ApiError(:final failure):
        if (isClosed) return;
        emit(AuthFailureState(failure.message));
    }
  }
}

class _GoogleSignInFlowException implements Exception {
  final String message;

  const _GoogleSignInFlowException(this.message);
}
