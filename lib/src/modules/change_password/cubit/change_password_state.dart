part of 'change_password_cubit.dart';

sealed class ChangePasswordState {}

final class ChangePasswordInitial extends ChangePasswordState {}

final class ChangePasswordInProgress extends ChangePasswordState {}

final class ChangePasswordSuccess extends ChangePasswordState {}

final class ChangePasswordError extends ChangePasswordState {
  final String message;

  ChangePasswordError({required this.message});
}
