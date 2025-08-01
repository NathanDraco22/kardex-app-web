part of 'client_read_cubit.dart';

sealed class ReadClientState {}

final class ReadClientInitial extends ReadClientState {}

final class ReadClientLoading extends ReadClientState {}

class ReadClientSuccess extends ReadClientState {
  final List<ClientInDb> clients;
  ReadClientSuccess(this.clients);
}

final class ReadClientSearching extends ReadClientSuccess {
  ReadClientSearching(super.clients);
}

class HighlightedClient extends ReadClientSuccess {
  List<ClientInDb> newClients;
  List<ClientInDb> updatedClients;
  HighlightedClient(
    super.clients, {
    this.newClients = const [],
    this.updatedClients = const [],
  });
}

final class ClientInserted extends ReadClientSuccess {
  int inserted;
  ClientInserted(this.inserted, super.clients);
}

final class ClientUpdated extends ReadClientSuccess {
  List<ClientInDb> updated;
  ClientUpdated(this.updated, super.clients);
}

final class ClientReadError extends ReadClientState {
  final String message;
  ClientReadError(this.message);
}
