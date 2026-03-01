part of 'read_client_transaction_cubit.dart';

sealed class ReadClientTransactionState {}

final class ReadClientTransactionInitial extends ReadClientTransactionState {}

final class ReadClientTransactionLoading extends ReadClientTransactionState {}

class ReadClientTransactionSuccess extends ReadClientTransactionState {
  final List<ClientTransactionInDb> transactions;
  final int totalCount;
  final ClientInDb client; // Contexto del Cliente

  ReadClientTransactionSuccess(
    this.transactions,
    this.totalCount, {
    required this.client,
  });
}

class FetchingNextPage extends ReadClientTransactionSuccess {
  FetchingNextPage(
    super.transactions,
    super.totalCount, {
    required super.client,
  });
}

final class ReadClientTransactionError extends ReadClientTransactionState {
  final String message;
  ReadClientTransactionError(this.message);
}
