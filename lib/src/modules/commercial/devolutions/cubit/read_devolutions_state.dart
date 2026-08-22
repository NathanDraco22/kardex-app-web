part of 'read_devolutions_cubit.dart';

sealed class ReadDevolutionsState {}

final class ReadDevolutionsInitial extends ReadDevolutionsState {}

final class ReadDevolutionsLoading extends ReadDevolutionsState {}

class ReadDevolutionsSuccess extends ReadDevolutionsState {
  final List<InvoiceInDb> invoices;
  final int totalCount;
  final InvoiceTotals totals;
  ReadDevolutionsSuccess(this.invoices, this.totalCount, this.totals);
}

class ReadDevolutionsLoadingMore extends ReadDevolutionsSuccess {
  ReadDevolutionsLoadingMore(super.invoices, super.totalCount, super.totals);
}

final class ReadDevolutionsSearchResult extends ReadDevolutionsState {
  final InvoiceInDb invoice;
  final List<DevolutionInDb> devolutions;
  ReadDevolutionsSearchResult(this.invoice, this.devolutions);
}

final class ReadDevolutionsError extends ReadDevolutionsState {
  final String message;
  ReadDevolutionsError(this.message);
}
