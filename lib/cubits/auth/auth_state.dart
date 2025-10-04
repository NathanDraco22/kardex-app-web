part of 'auth_cubit.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class Authenticated extends AuthState {
  final LoginResponse session;
  final BranchInDb branch;
  Authenticated(this.session, this.branch);
}

final class Unauthenticated extends AuthState {}

final class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
