part of 'read_active_users_cubit.dart';

sealed class ReadActiveUsersState {}

final class ReadActiveUsersInitial extends ReadActiveUsersState {}

final class ReadActiveUsersLoading extends ReadActiveUsersState {}

final class ReadActiveUsersSuccess extends ReadActiveUsersState {
  final List<UserInDbWithRole> users;

  ReadActiveUsersSuccess(this.users);
}

final class ReadActiveUsersError extends ReadActiveUsersState {
  final String message;

  ReadActiveUsersError(this.message);
}
