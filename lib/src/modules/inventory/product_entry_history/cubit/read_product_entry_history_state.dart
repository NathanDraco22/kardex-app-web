part of 'read_product_entry_history_cubit.dart';

sealed class ReadProductEntryHistoryState {}

final class ReadProductEntryHistoryInitial extends ReadProductEntryHistoryState {}

final class ReadProductEntryHistoryLoading extends ReadProductEntryHistoryState {}

final class ReadProductEntryHistorySuccess extends ReadProductEntryHistoryState {
  final List<EntryHistoryInDb> entryHistories;
  final ProductInDb product;

  ReadProductEntryHistorySuccess(this.entryHistories, this.product);
}

final class ReadProductEntryHistoryError extends ReadProductEntryHistoryState {
  final String message;

  ReadProductEntryHistoryError(this.message);
}
