part of 'write_terminal_invoice_cubit.dart';

sealed class WriteTerminalInvoiceState {}

final class WriteTerminalInvoiceInitial extends WriteTerminalInvoiceState {}

final class WriteTerminalInvoiceInProgress extends WriteTerminalInvoiceState {}

final class WriteTerminalInvoiceSuccess extends WriteTerminalInvoiceState {
  final InvoiceInDb invoice;
  WriteTerminalInvoiceSuccess(this.invoice);
}

final class WriteTerminalInvoiceError extends WriteTerminalInvoiceState {
  final String message;
  WriteTerminalInvoiceError(this.message);
}
