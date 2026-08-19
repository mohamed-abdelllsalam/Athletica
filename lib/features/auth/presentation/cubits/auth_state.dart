import 'package:athletica/features/auth/domain/entities/auth_status.dart';
import 'package:athletica/features/auth/domain/entities/user_entity.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class LoginSuccess extends AuthState {
  final AuthResponseEntity response;
  LoginSuccess(this.response);
}

final class RegisterSuccess extends AuthState {}

final class VerificationLoading extends AuthState {}

final class VerificationSuccess extends AuthState {}

final class VerificationCodeResent extends AuthState {}

final class AuthStatusChecked extends AuthState {
  final AuthStatus status;
  AuthStatusChecked(this.status);
}

final class EmailVerificationRequired extends AuthState {
  final String message;
  EmailVerificationRequired(this.message);
}

final class AuthFailureState extends AuthState {
  final String message;
  AuthFailureState(this.message);
}
