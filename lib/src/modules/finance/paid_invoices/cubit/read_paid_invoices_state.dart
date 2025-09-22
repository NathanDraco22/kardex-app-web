part of 'read_paid_invoices_cubit.dart';

sealed class ReadPaidInvoicesState {}

final class ReadPaidInvoicesInitial extends ReadPaidInvoicesState {}

final class ReadPaidInvoicesLoading extends ReadPaidInvoicesState {}

class ReadPaidInvoicesSuccess extends ReadPaidInvoicesState {
  final List<InvoiceInDb> invoices;
  final int totalCount;
  final InvoiceTotals totals;
  ReadPaidInvoicesSuccess(this.invoices, this.totalCount, this.totals);
}

class ReadSearchingInvoice extends ReadPaidInvoicesSuccess {
  ReadSearchingInvoice(super.invoices, super.totalCount, super.totals);
}

final class ReadPaidInvoicesError extends ReadPaidInvoicesState {
  final String message;
  ReadPaidInvoicesError(this.message);
}
