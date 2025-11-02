part of 'read_invoice_cubit.dart';

sealed class ReadInvoiceState {}

final class ReadInvoiceInitial extends ReadInvoiceState {}

final class ReadInvoiceLoading extends ReadInvoiceState {}

final class ReadInvoiceSuccess extends ReadInvoiceState {
  final List<InvoiceInDb> invoices;
  final List<DevolutionInDb> devolutions;
  final int totalCount;
  ReadInvoiceSuccess(this.invoices, this.totalCount, {required this.devolutions});
}

final class ReadInvoiceError extends ReadInvoiceState {
  final String message;
  ReadInvoiceError(this.message);
}
