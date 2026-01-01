part of 'read_adjust_entry_history_cubit.dart';

sealed class ReadAdjustEntryHistoryState {}

final class ReadAdjustEntryHistoryInitial extends ReadAdjustEntryHistoryState {}

final class ReadAdjustEntryHistoryLoading extends ReadAdjustEntryHistoryState {}

class ReadAdjustEntryHistorySuccess extends ReadAdjustEntryHistoryState {
  final List<AdjustEntryInDb> entries;
  // Adjust entries don't have a separate totals object in the repository scan,
  // so I'm omitting totals for now or will calculate locally if needed for the UI total display.
  // The invoice history UI shows a total column in the table per row, but maybe a grand total?
  // InvoiceHistoryState had InvoiceTotals. If AdjustEntries doesn't have it, I'll exclude it to avoid compilation error.
  ReadAdjustEntryHistorySuccess(this.entries);
}

final class FetchingNextPage extends ReadAdjustEntryHistorySuccess {
  FetchingNextPage(super.entries);
}

final class ReadAdjustEntryHistoryError extends ReadAdjustEntryHistoryState {
  final String message;
  ReadAdjustEntryHistoryError(this.message);
}
