import 'package:athletica/features/auth/domain/entities/user_entity.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class LoginSuccess extends AuthState {
  final AuthResponseEntity response;
  LoginSuccess(this.response);
}

final class RegisterSuccess extends AuthState {}

final class AuthFailureState extends AuthState {
  final String message;
  AuthFailureState(this.message);
}
