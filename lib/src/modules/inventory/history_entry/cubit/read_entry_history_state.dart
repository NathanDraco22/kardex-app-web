part of 'read_entry_history_cubit.dart';

sealed class ReadEntryHistoryState {}

final class ReadEntryHistoryInitial extends ReadEntryHistoryState {}

final class ReadEntryHistoryLoading extends ReadEntryHistoryState {}

final class ReadEntryHistorySuccess extends ReadEntryHistoryState {
  final List<EntryHistoryInDb> histories;
  final int totalCount;
  ReadEntryHistorySuccess(this.histories, this.totalCount);
}

final class ReadEntryHistoryError extends ReadEntryHistoryState {
  final String message;
  ReadEntryHistoryError(this.message);
}
