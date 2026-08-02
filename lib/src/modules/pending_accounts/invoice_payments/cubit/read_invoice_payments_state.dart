part of 'read_invoice_payments_cubit.dart';

sealed class ReadInvoicePaymentsState {}

final class ReadInvoicePaymentsInitial extends ReadInvoicePaymentsState {}

final class ReadInvoicePaymentsLoading extends ReadInvoicePaymentsState {}

class ReadInvoicePaymentsSuccess extends ReadInvoicePaymentsState {
  final List<InvoiceInDb> invoices;
  final int totalCount;

  ReadInvoicePaymentsSuccess(this.invoices, this.totalCount);
}

class ReadInvoicePaymentsSearching extends ReadInvoicePaymentsSuccess {
  ReadInvoicePaymentsSearching(super.invoices, super.totalCount);
}

final class ReadInvoicePaymentsError extends ReadInvoicePaymentsState {
  final String message;

  ReadInvoicePaymentsError(this.message);
}
