part of 'client_write_cubit.dart';

sealed class ClientWriteState {}

final class ClientWriteInitial extends ClientWriteState {}

final class ClientWriteInProgress extends ClientWriteState {}

final class ClientWriteSuccess extends ClientWriteState {
  final ClientInDb client;
  ClientWriteSuccess(this.client);
}

final class ClientDeleteSuccess extends ClientWriteState {
  final ClientInDb client;
  ClientDeleteSuccess(this.client);
}

final class ClientWriteError extends ClientWriteState {
  final String error;
  ClientWriteError(this.error);
}
