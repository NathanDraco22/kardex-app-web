part of 'write_invoice_cubit.dart';

sealed class WriteInvoiceState {}

final class WriteInvoiceInitial extends WriteInvoiceState {}

final class WriteInvoiceInProgress extends WriteInvoiceState {}

final class WriteInvoiceSuccess extends WriteInvoiceState {
  InvoiceInDb? createdInvoice;
  WriteInvoiceSuccess(this.createdInvoice);
}

final class WriteInvoiceError extends WriteInvoiceState {
  final String error;
  WriteInvoiceError(this.error);
}
