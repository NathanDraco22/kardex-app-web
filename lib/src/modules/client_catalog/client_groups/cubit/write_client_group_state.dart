part of 'write_client_group_cubit.dart';

sealed class WriteClientGroupState {}

final class WriteClientGroupInitial extends WriteClientGroupState {}

final class WriteClientGroupInProgress extends WriteClientGroupState {}

final class WriteClientGroupSuccess extends WriteClientGroupState {
  final ClientGroupInDb clientGroup;
  WriteClientGroupSuccess(this.clientGroup);
}

final class DeleteClientGroupSuccess extends WriteClientGroupState {
  final ClientGroupInDb clientGroup;
  DeleteClientGroupSuccess(this.clientGroup);
}

final class WriteClientGroupError extends WriteClientGroupState {
  final String error;
  WriteClientGroupError(this.error);
}
