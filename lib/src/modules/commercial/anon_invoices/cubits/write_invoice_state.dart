part of 'write_invoice_cubit.dart';

sealed class WriteAnonInvoiceState {}

final class WriteAnonInvoiceInitial extends WriteAnonInvoiceState {}

final class WriteAnonInvoiceInProgress extends WriteAnonInvoiceState {}

final class WriteAnonInvoiceSuccess extends WriteAnonInvoiceState {
  final InvoiceInDb invoice;
  WriteAnonInvoiceSuccess(this.invoice);
}

final class WriteAnonInvoiceError extends WriteAnonInvoiceState {
  final String error;
  WriteAnonInvoiceError(this.error);
}
