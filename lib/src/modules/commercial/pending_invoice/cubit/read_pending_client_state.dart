part of 'read_pending_client_cubit.dart';

sealed class ReadPendingClientState {}

final class ReadPendingClientInitial extends ReadPendingClientState {}

final class ReadPendingClientLoading extends ReadPendingClientState {}

class ReadPendingClientSuccess extends ReadPendingClientState {
  final List<ClientInDb> clients;
  ReadPendingClientSuccess(this.clients);
}

final class ReadNextPagePendingClientSuccess extends ReadPendingClientSuccess {
  ReadNextPagePendingClientSuccess(super.clients);
}

final class ReadPendingClientError extends ReadPendingClientState {
  final String message;
  ReadPendingClientError(this.message);
}
