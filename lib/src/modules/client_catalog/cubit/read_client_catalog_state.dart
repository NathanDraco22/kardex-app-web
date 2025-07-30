part of 'read_client_catalog_cubit.dart';

sealed class ClientCatalogState {}

final class ClientCatalogInitial extends ClientCatalogState {}

final class ClientCatalogLoading extends ClientCatalogState {}

class ClientCatalogSuccess extends ClientCatalogState {
  final List<ClientInDb> clients;
  ClientCatalogSuccess(this.clients);
}

final class ClientCatalogSearching extends ClientCatalogSuccess {
  ClientCatalogSearching(super.clients);
}

class HighlightedClient extends ClientCatalogSuccess {
  List<ClientInDb> newClients;
  List<ClientInDb> updatedClients;
  HighlightedClient(
    super.clients, {
    this.newClients = const [],
    this.updatedClients = const [],
  });
}

final class ClientInserted extends ClientCatalogSuccess {
  int inserted;
  ClientInserted(this.inserted, super.clients);
}

final class ClientUpdated extends ClientCatalogSuccess {
  List<ClientInDb> updated;
  ClientUpdated(this.updated, super.clients);
}

final class ClientCatalogError extends ClientCatalogState {
  final String message;
  ClientCatalogError(this.message);
}
