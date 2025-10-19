part of 'auth_cubit.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthInactive extends AuthState {}

final class Authenticated extends AuthState {
  final LoginResponse session;
  final BranchInDb branch;
  final Servin servin;
  Authenticated(this.session, this.branch, this.servin);
}

final class Unauthenticated extends AuthState {
  Servin? servin;
  Unauthenticated({this.servin});
}

final class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
