part of 'read_user_cubit.dart';

sealed class ReadUserState {}

final class ReadUserInitial extends ReadUserState {}

final class ReadUserLoading extends ReadUserState {}

class ReadUserSuccess extends ReadUserState {
  final List<UserInDbWithRole> users;
  final List<UserRoleInDb> roles;
  final List<BranchInDb> branches;
  ReadUserSuccess(this.users, this.roles, this.branches);
}

final class ReadUserSearching extends ReadUserSuccess {
  ReadUserSearching(super.users, super.roles, super.branches);
}

class HighlightedUser extends ReadUserSuccess {
  List<UserInDb> newUsers;
  List<UserInDb> updatedUsers;
  HighlightedUser(
    super.users,
    super.roles,
    super.branches, {
    this.newUsers = const [],
    this.updatedUsers = const [],
  });
}

final class ReadUserError extends ReadUserState {
  final String message;
  ReadUserError(this.message);
}
