part of 'read_receipt_history_cubit.dart';

sealed class ReadReceiptHistoryState {}

final class ReadReceiptHistoryInitial extends ReadReceiptHistoryState {}

final class ReadReceiptHistoryLoading extends ReadReceiptHistoryState {}

class ReadReceiptHistorySuccess extends ReadReceiptHistoryState {
  final List<ReceiptInDb> receipts;
  ReadReceiptHistorySuccess(this.receipts);
}

final class FetchingNextPage extends ReadReceiptHistorySuccess {
  FetchingNextPage(super.receipts);
}

final class ReadReceiptHistoryError extends ReadReceiptHistoryState {
  final String message;
  ReadReceiptHistoryError(this.message);
}
