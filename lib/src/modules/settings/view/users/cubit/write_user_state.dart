part of 'write_user_cubit.dart';

sealed class WriteUserState {}

final class WriteUserInitial extends WriteUserState {}

final class WriteUserInProgress extends WriteUserState {}

final class WriteUserSuccess extends WriteUserState {
  final UserInDb user;
  WriteUserSuccess(this.user);
}

final class UpdateUserSuccess extends WriteUserState {
  final UserInDb user;
  UpdateUserSuccess(this.user);
}

final class DeleteUserSuccess extends WriteUserState {
  final UserInDb user;
  DeleteUserSuccess(this.user);
}

final class WriteUserError extends WriteUserState {
  final String error;
  WriteUserError(this.error);
}
