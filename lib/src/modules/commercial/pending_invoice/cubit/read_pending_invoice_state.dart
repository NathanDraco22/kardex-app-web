part of 'read_pending_invoice_cubit.dart';

sealed class ReadInvoiceState {}

final class ReadInvoiceInitial extends ReadInvoiceState {}

final class ReadInvoiceLoading extends ReadInvoiceState {}

final class ReadInvoiceSuccess extends ReadInvoiceState {
  final List<InvoiceInDb> invoices;
  final List<DevolutionInDb> devolutions;
  final List<CreditNoteInDb> creditNotes;
  final int totalCount;
  final PendingCheckoutSummary? summary;

  ReadInvoiceSuccess(
    this.invoices,
    this.totalCount, {
    required this.devolutions,
    this.creditNotes = const [],
    this.summary,
  });
}

final class ReadInvoiceError extends ReadInvoiceState {
  final String message;
  ReadInvoiceError(this.message);
}
