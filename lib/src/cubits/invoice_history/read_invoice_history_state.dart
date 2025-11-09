part of 'read_invoice_history_cubit.dart';

sealed class ReadInvoiceHistoryState {}

final class ReadInvoiceHistoryInitial extends ReadInvoiceHistoryState {}

final class ReadInvoiceHistoryLoading extends ReadInvoiceHistoryState {}

class ReadInvoiceHistorySuccess extends ReadInvoiceHistoryState {
  final List<InvoiceInDb> invoices;
  ReadInvoiceHistorySuccess(this.invoices);
}

final class FetchingNextPage extends ReadInvoiceHistorySuccess {
  FetchingNextPage(super.invoices);
}

final class ReadInvoiceHistoryError extends ReadInvoiceHistoryState {
  final String message;
  ReadInvoiceHistoryError(this.message);
}
