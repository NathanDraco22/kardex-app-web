part of 'read_daily_client_invoices_cubit.dart';

sealed class ReadDailyClientInvoicesState {}

final class ReadDailyClientInvoicesInitial extends ReadDailyClientInvoicesState {}

final class ReadDailyClientInvoicesLoading extends ReadDailyClientInvoicesState {}

class ReadDailyClientInvoicesSuccess extends ReadDailyClientInvoicesState {
  final List<InvoiceInDb> invoices;
  final int totalCount;
  final InvoiceTotals totals;
  ReadDailyClientInvoicesSuccess(this.invoices, this.totalCount, this.totals);
}

class ReadDailyClientInvoicesLoadingMore extends ReadDailyClientInvoicesSuccess {
  ReadDailyClientInvoicesLoadingMore(super.invoices, super.totalCount, super.totals);
}

final class ReadDailyClientInvoicesError extends ReadDailyClientInvoicesState {
  final String message;
  ReadDailyClientInvoicesError(this.message);
}
