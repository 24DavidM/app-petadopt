import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String role;

  const RegisterEvent(this.email, this.password, this.name, this.role);

  @override
  List<Object> get props => [email, password, name, role];
}

class GoogleSignInEvent extends AuthEvent {}

class UpdateRoleEvent extends AuthEvent {
  final String role;

  const UpdateRoleEvent(this.role);

  @override
  List<Object> get props => [role];
}

class LogoutEvent extends AuthEvent {}

class ResetPasswordEvent extends AuthEvent {
  final String email;

  const ResetPasswordEvent(this.email);

  @override
  List<Object> get props => [email];
}

class CheckAuthStatusEvent extends AuthEvent {}

class RefreshUserEvent extends AuthEvent {}
