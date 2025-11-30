part of 'read_product_transaction_cubit.dart';

sealed class ReadProductTransactionState {}

final class ReadProductTransactionInitial extends ReadProductTransactionState {}

final class ReadProductTransactionLoading extends ReadProductTransactionState {}

class ReadProductTransactionSuccess extends ReadProductTransactionState {
  final List<ProductTransactionInDb> transactions;
  final ProductInDb product;
  final int totalCount;
  ReadProductTransactionSuccess(this.transactions, this.totalCount, {required this.product});
}

class FetchingNextPage extends ReadProductTransactionSuccess {
  FetchingNextPage(super.transactions, super.totalCount, {required super.product});
}

final class ReadProductTransactionError extends ReadProductTransactionState {
  final String message;
  ReadProductTransactionError(this.message);
}
