part of 'client_catalog_cubit.dart';

sealed class ClientCatalogState {}

final class ClientCatalogInitial extends ClientCatalogState {}

final class ClientCatalogLoading extends ClientCatalogState {}

final class ClientCatalogSuccess extends ClientCatalogState {
  final List<ClientInDb> clients;
  ClientCatalogSuccess(this.clients);
}

final class ClientCatalogError extends ClientCatalogState {
  final String message;
  ClientCatalogError(this.message);
}
