part of 'client_read_cubit.dart';

sealed class ReadClientState {}

final class ReadClientInitial extends ReadClientState {}

final class ReadClientLoading extends ReadClientState {}

class ReadClientSuccess extends ReadClientState {
  final List<ClientInDb> clients;
  final int totalBalance;
  final bool isSearchActive;

  ReadClientSuccess(
    this.clients, {
    this.totalBalance = 0,
    this.isSearchActive = false,
  });

  int get filteredBalance => clients.fold<int>(0, (sum, c) => sum + c.balance);
  int get totalDebtorsCount => clients.where((c) => c.balance > 0).length;
}

final class ReadClientSearching extends ReadClientSuccess {
  ReadClientSearching(
    super.clients, {
    super.totalBalance = 0,
    super.isSearchActive = true,
  });
}

class HighlightedClient extends ReadClientSuccess {
  List<ClientInDb> newClients;
  List<ClientInDb> updatedClients;
  HighlightedClient(
    super.clients, {
    super.totalBalance = 0,
    this.newClients = const [],
    this.updatedClients = const [],
    super.isSearchActive = false,
  });
}

final class ClientInserted extends ReadClientSuccess {
  int inserted;
  ClientInserted(
    this.inserted,
    super.clients, {
    super.totalBalance = 0,
    super.isSearchActive = false,
  });
}

final class ClientUpdated extends ReadClientSuccess {
  List<ClientInDb> updated;
  ClientUpdated(
    this.updated,
    super.clients, {
    super.totalBalance = 0,
    super.isSearchActive = false,
  });
}

final class ClientReadError extends ReadClientState {
  final String message;
  ClientReadError(this.message);
}
