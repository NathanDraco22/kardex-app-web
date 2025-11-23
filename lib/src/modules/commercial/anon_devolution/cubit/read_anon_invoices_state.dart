part of 'read_anon_invoices_cubit.dart';

sealed class ReadAnonInvoicesState {}

final class ReadAnonInvoicesInitial extends ReadAnonInvoicesState {}

final class ReadAnonInvoicesInProgress extends ReadAnonInvoicesState {}

final class ReadAnonInvoicesSuccess extends ReadAnonInvoicesState {
  final InvoiceInDb invoice;
  final List<DevolutionInDb> devolutions;
  ReadAnonInvoicesSuccess(this.invoice, this.devolutions);
}

final class ReadAnonInvoicesError extends ReadAnonInvoicesState {
  final String message;
  ReadAnonInvoicesError(this.message);
}
