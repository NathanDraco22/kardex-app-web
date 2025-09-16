part of 'client_write_cubit.dart';

sealed class WriteClientState {}

final class WriteClientInitial extends WriteClientState {}

final class WriteClientInProgress extends WriteClientState {}

final class WriteClientSuccess extends WriteClientState {
  final ClientInDb client;
  WriteClientSuccess(this.client);
}

final class DeleteClientSuccess extends WriteClientState {
  final ClientInDb client;
  DeleteClientSuccess(this.client);
}

final class WriteClientError extends WriteClientState {
  final String error;
  WriteClientError(this.error);
}
