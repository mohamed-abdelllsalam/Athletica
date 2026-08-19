import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/login_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/logout_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/register_client_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/register_trainer_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterClientUseCase _registerClientUseCase;
  final RegisterTrainerUseCase _registerTrainerUseCase;
  final VerifyEmailUseCase _verifyEmailUseCase;
  final ResendVerificationUseCase _resendVerificationUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterClientUseCase registerClientUseCase,
    required RegisterTrainerUseCase registerTrainerUseCase,
    required VerifyEmailUseCase verifyEmailUseCase,
    required ResendVerificationUseCase resendVerificationUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerClientUseCase = registerClientUseCase,
        _registerTrainerUseCase = registerTrainerUseCase,
        _verifyEmailUseCase = verifyEmailUseCase,
        _resendVerificationUseCase = resendVerificationUseCase,
        _logoutUseCase = logoutUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        super(AuthInitial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await _loginUseCase(email: email, password: password);
    switch (result) {
      case ApiSuccess(:final data):
        emit(LoginSuccess(data));
      case ApiError(:final failure):
        if (failure is EmailNotVerifiedFailure) {
          emit(EmailVerificationRequired(failure.message));
        } else {
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
        emit(RegisterSuccess());
      case ApiError(:final failure):
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
        emit(RegisterSuccess());
      case ApiError(:final failure):
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
        emit(VerificationSuccess());
      case ApiError(:final failure):
        emit(AuthFailureState(failure.message));
    }
  }

  Future<void> resendVerification({required String email}) async {
    emit(VerificationLoading());
    final result = await _resendVerificationUseCase(email: email);
    switch (result) {
      case ApiSuccess():
        emit(VerificationCodeResent());
      case ApiError(:final failure):
        emit(AuthFailureState(failure.message));
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final status = await _checkAuthStatusUseCase();
      emit(AuthStatusChecked(status));
    } catch (e) {
      emit(AuthFailureState('Failed to verify session. Please try again.'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    final result = await _logoutUseCase();
    switch (result) {
      case ApiSuccess():
        emit(AuthInitial());
      case ApiError(:final failure):
        emit(AuthFailureState(failure.message));
    }
  }
}
