import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/login_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/logout_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/register_client_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/register_trainer_usecase.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterClientUseCase _registerClientUseCase;
  final RegisterTrainerUseCase _registerTrainerUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterClientUseCase registerClientUseCase,
    required RegisterTrainerUseCase registerTrainerUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerClientUseCase = registerClientUseCase,
        _registerTrainerUseCase = registerTrainerUseCase,
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
        emit(AuthFailureState(failure.message));
    }
  }

  Future<void> registerClient({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await _registerClientUseCase(
      name: name,
      phone: phone,
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
    required String phone,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await _registerTrainerUseCase(
      name: name,
      phone: phone,
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

  Future<void> checkAuthStatus() async {
    final status = await _checkAuthStatusUseCase();
    emit(AuthStatusChecked(status));
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
