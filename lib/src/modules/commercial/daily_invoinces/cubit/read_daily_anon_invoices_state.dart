part of 'read_daily_anon_invoices_cubit.dart';

sealed class ReadDailyAnonInvoicesState {}

final class ReadDailyAnonInvoicesInitial extends ReadDailyAnonInvoicesState {}

final class ReadDailyAnonInvoicesLoading extends ReadDailyAnonInvoicesState {}

class ReadDailyAnonInvoicesSuccess extends ReadDailyAnonInvoicesState {
  final List<InvoiceInDb> invoices;
  final int totalCount;
  final InvoiceTotals totals;
  ReadDailyAnonInvoicesSuccess(this.invoices, this.totalCount, this.totals);
}

class ReadSearchingInvoice extends ReadDailyAnonInvoicesSuccess {
  ReadSearchingInvoice(super.invoices, super.totalCount, super.totals);
}

final class ReadDailyAnonInvoicesError extends ReadDailyAnonInvoicesState {
  final String message;
  ReadDailyAnonInvoicesError(this.message);
}
