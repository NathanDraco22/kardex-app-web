part of 'read_daily_invoices_cubit.dart';

sealed class ReadDailyInvoicesState {}

final class ReadDailyInvoicesInitial extends ReadDailyInvoicesState {}

final class ReadDailyInvoicesLoading extends ReadDailyInvoicesState {}

class ReadDailyInvoicesSuccess extends ReadDailyInvoicesState {
  final List<InvoiceInDb> invoices;
  final int totalCount;
  final InvoiceTotals totals;
  ReadDailyInvoicesSuccess(this.invoices, this.totalCount, this.totals);
}

class ReadSearchingInvoice extends ReadDailyInvoicesSuccess {
  ReadSearchingInvoice(super.invoices, super.totalCount, super.totals);
}

final class ReadDailyInvoicesError extends ReadDailyInvoicesState {
  final String message;
  ReadDailyInvoicesError(this.message);
}
